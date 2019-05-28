import Foundation

enum InterpreterException: ParrotError {
    case cannotParseFeature
    case unexpectedEOF
    case unexpectedLine(ScannerElementDescriptor)
}

class CucumberInterpreter: Interpreter {    
    
    let scanner: Scanner
    
    private let lines: [ScannerElementDescriptor]
    private var lineRepository: IndexingIterator<[ScannerElementDescriptor]>
    private var currentLine: ScannerElementDescriptor
    private var tagsBuffer: [ASTNode<Tag>] = []
    private(set) var commentsLine : [CommentScannerElement] = []
    
    init(scanner: Scanner) throws {
        self.scanner = scanner
        
        lines = try scanner.parseLines()
            .get()
            .lazy
            .sorted(by: { e1, e2 in e1.key < e2.key })
            .filter({ !($0.value is EmptyScannerElement) })
            .compactMap { $0.value }

        lineRepository = lines.makeIterator()
        currentLine = try lineRepository.next() ?! InterpreterException.cannotParseFeature
    }
    
    func parse() throws -> ASTNode<Feature>? {
        return try feature()
    }
    
    private func consume() {
        repeat {
            guard !currentLine.isOf(type: .eof) else {
                return
            }
            if let comment = currentLine as? CommentScannerElement {
                commentsLine.append(comment)
            }
        
            currentLine = lineRepository.next()!
        } while currentLine is CommentScannerElement
    }
    
    // tags -> FEATURE: -> title_description -> scenarios -> EOF
    private func feature() throws -> ASTNode<Feature>? {
        let tagList = tags()
        
        let language: String
        if let languageLine = currentLine as? LanguageScannerElement {
            language = languageLine.text
            consume()
        } else {
            language = "en"
        }
        
        guard currentLine.isOf(type: .feature) else {
            if currentLine.isOf(type: .eof) {
                return nil
            }
            if commentsLine.isEmpty && !(currentLine is CommentScannerElement) {
                throw InterpreterException.cannotParseFeature
            }
            return nil
        }
        
        let featureLocation = currentLine.location
        let keyword = currentLine.keywordIdentifier

        let titleDesc = titleDescription()
        let scenarioList = try scenarios()
        let ruleList = try rules()
        
        guard currentLine.isOf(type: .eof) else {
            throw InterpreterException.unexpectedEOF
        }
        
        return ASTNode(
            Feature(
                language: language,
                tags: tagList,
                keyword: keyword,
                title: titleDesc.title,
                description: titleDesc.description,
                scenarios: scenarioList,
                rules: ruleList
            ),
            location: featureLocation
        )
    }
    
    
    private func sentences() -> String? {
        var content = ""
        
        while currentLine.isOf(type: .other) {
            content.append(currentLine.text)
            consume()
        }

        return content.trimmed
    }
    
    private func titleDescription() -> (title: String?, description: String?) {
        let title = currentLine.text
        
        if currentLine.isOf(type: .step) {
            return (title: title, description: nil)
        } else {
            consume()
            return (title: title, description: sentences())
        }
    }
    
    // @tag*
    private func tags() -> [ASTNode<Tag>] {
        var tagsList: [ASTNode<Tag>] = []
        
        while let tagElement = currentLine as? TagLineScannerElement {
            tagsList.append(contentsOf: tagElement.items.map {
                ASTNode(Tag(tag: $0.value), location: $0.location)
            })
            consume()
        }
        
        return tagsList
    }
    
    // scenario | scenario*
    private func scenarios() throws -> [ASTNode<Scenario>] {
        var scenarioList: [ASTNode<Scenario>] = []
        
        while let scenario = try scenario() {
            scenarioList.append(scenario)
        }
        
        return scenarioList
    }

    private func rules() throws -> [ASTNode<Rule>] {
        var ruleList: [ASTNode<Rule>] = []
        
        while let rule = try rule() {
            ruleList.append(rule)
        }
        
        return ruleList
    }
    
    private func rule() throws -> ASTNode<Rule>? {
        guard currentLine.isOf(type: .rule) else {
            return nil
        }
        
        let location = currentLine.location
        let titleDesc = titleDescription()
        
        return ASTNode(Rule(
            title: titleDesc.title,
            description: titleDesc.description,
            scenarios: try scenarios()
        ), location: location)
    }
    
    // tags -> SCENARIO KEY -> title_description -> steps -> examples
    private func scenario() throws -> ASTNode<Scenario>? {
        // tags
        let tagList: [ASTNode<Tag>]
        if tagsBuffer.isEmpty {
            tagList = tags()
        } else {
            tagList = tagsBuffer
            tagsBuffer.removeAll()
        }
        
        // SCENARIO KEY
        guard currentLine.isOf(type: .scenario) || currentLine.isOf(type: .background) else {
            if tagList.isEmpty {
                return nil
            }
            
            throw InterpreterException.unexpectedLine(currentLine)
        }
        
        let location = currentLine.location
        let isOutline = currentLine.isScenarioOutline
        let keyword = currentLine.keywordIdentifier
        
        // title_description
        let titleDesc = titleDescription()

        let scenario = Scenario(
            tags: tagList,
            keyword: keyword,
            title: titleDesc.title,
            description: titleDesc.description,
            steps: try steps(),
            isOutline: isOutline,
            examples: try outline()
        )
        
        return ASTNode(scenario, location: location)
    }
    
    // tags* -> (Examples -> DataTable)*
    private func outline() throws -> [ASTNode<ExamplesTable>] {
        var exampleTables: [ASTNode<ExamplesTable>] = []
        
        while currentLine.isOf(type: .tag) || currentLine.isOf(type: .examples) {
            let tagList = tags()
            
            if currentLine.isOf(type: .scenario) {
                tagsBuffer = tagList
                break
            }
            
            if let exampleTable = try examples(tags: tagList) {
                exampleTables.append(exampleTable)
            }
            
            consume()
        }
        
        return exampleTables
    }
    
    // Examples: -> title* -> columns_title -> data_table ->
    private func examples(tags: [ASTNode<Tag>]) throws -> ASTNode<ExamplesTable>? {
        // Examples:
        guard currentLine.isOf(type: .examples) else {
            return nil
        }
        
        let location = currentLine.location
        let keyword = currentLine.keywordIdentifier
        
        let titleDesc = titleDescription()
        let table = try dataTable()
        
        let examplesTable = ExamplesTable(
            keyword: keyword,
            title: titleDesc.title,
            description: titleDesc.description,
            tags: tags,
            dataTable: table
        )
        
        return ASTNode(examplesTable, location: location)
    }
    
    // PIPE -> (expression -> PIPE)* ->
    private func dataTable() throws -> ASTNode<DataTable>? {
        guard currentLine.isOf(type: .tableRow) else {
            return nil
        }
        
        var rows: [ASTNode<DataTable.Row>] = []
        
        let location = currentLine.location
        
        while let tableRow = currentLine as? TableRowScannerElement {
            let location = tableRow.location
            let cells = tableRow.items.map {
                ASTNode(DataTable.Cell.value($0.value), location: $0.location)
            }
            
            rows.append(ASTNode(DataTable.Row(cells: cells), location: location))
            consume()
        }
        
        let dataTable = try DataTable(rows: rows)

        return ASTNode(dataTable, location: location)
    }
    
    private func docString() throws -> ASTNode<DocString>? {
        guard let docStringLine = currentLine as? DocStringSeparatorScannerElement else {
            return nil
        }
        
        let location = docStringLine.location
        let mark = docStringLine.mark
        consume()
        
        var content = ""
        
        while currentLine.isOf(type: .other) {
            content += currentLine.text
            consume()
        }
        
        guard currentLine.isOf(type: .docString) else {
            throw InterpreterException.unexpectedLine(currentLine)
        }
        consume()
        
        let docString = DocString(
            mark: mark,
            content: content,
            delimiter: docStringLine.delimiter
        )
        
        return ASTNode(docString, location: location)
    }
    
    private func steps() throws -> [ASTNode<Step>] {
        var stepList: [ASTNode<Step>] = []
        
        while currentLine.isOf(type: .step) {
            stepList.append(try step())
        }
        
        return stepList
    }
    
    // STEPKEYWORD -> step_text -> (data_table | doc_string)* ->
    private func step() throws -> ASTNode<Step> {
        guard let stepLine = currentLine as? StepLineScannerElement else {
            throw InterpreterException.unexpectedLine(currentLine)
        }
        
        consume()
        
        let keyword = Step.Keyword(keyword: stepLine.keywordIdentifier, type: stepLine.keyword)
        
        let step = try Step(
            keyword: keyword,
            text: stepLine.text,
            docString: try docString(),
            dataTable: try dataTable()
        )
        
        return ASTNode(step, location: stepLine.location)
    }

}

extension ScannerElementDescriptor {
    
    var isScenarioOutline: Bool {
        guard let scenario = self as? ScenarioLineScannerElement else {
            return false
        }
        return scenario.tokens.first?.isScenarioOutlineKeyword ?? false
    }
    
}
