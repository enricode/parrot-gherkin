import Foundation

enum InterpreterException: ParrotError {
    case unexpectedTerm(term: TokenType, expected: TokenType)
    case titleExpectedNothingFound
    case textExpectedNothingFound
    case scenarioOutlineWithoutExamples
    case unexpectedTitleDescriptionFactor
    case exampleTableWithoutTitle
    case exampleTableWithoutRows
    case expectedDataTableToken
    
    case incorrectDataTable
    case cannotParseFeature
}

class CucumberInterpreter: Interpreter {    
    
    enum Mode {
        case strict
        case permissive
    }
    
    let lexer: Lexer
    
    private var currentToken: Token
    private let mode: CucumberInterpreter.Mode
    private var tagsBuffer: [ASTNode<Tag>] = []
    private(set) var commentsTokens: [Token] = []
    
    init(lexer: Lexer, mode: CucumberInterpreter.Mode = .permissive) throws {
        self.lexer = lexer
        self.mode = mode

        currentToken = try lexer.getNextToken()
    }
    
    func parse() throws -> ASTNode<Feature>? {
        let parsedFeature = try feature()
        
        if let feature = parsedFeature {
            let validFeature = try FeatureValidator(mode: mode).validate(object: feature.element)
            
            guard validFeature else {
                throw InterpreterException.cannotParseFeature
            }
        }
        
        return parsedFeature
    }
    
    private func eat() throws {
        repeat {
            currentToken = try lexer.getNextToken()
            
            if currentToken == CommentKeyword.self {
                commentsTokens.append(currentToken)
            }
        } while currentToken == CommentKeyword.self
    }
    
    // tags -> FEATURE: -> title_description -> scenarios -> EOF
    private func feature() throws -> ASTNode<Feature>? {
        let tagList = try tags()
        
        guard currentToken == PrimaryKeyword.feature else {
            return nil
        }
        
        let featureLocation = currentToken.location
        try eat() // Feature token
        
        let titleDesc = try titleDescription()
        let scenarioList = try scenarios()
        
        guard currentToken == EOF() else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: EOF())
        }
        
        return ASTNode(
            Feature(
                tags: tagList,
                title: titleDesc.title,
                description: titleDesc.description,
                scenarios: scenarioList
            ),
            location: featureLocation
        )
    }
    
    private func sentence() throws -> String? {
        guard let expressionToken = currentToken.type as? Expression else {
            return nil
        }
        
        try eat()
        
        return expressionToken.content
    }
    
    private func titleDescription() throws -> (title: String?, description: String?) {
        let title = try sentence()
        
        if mode == .strict, title == nil {
            throw InterpreterException.titleExpectedNothingFound
        }
        
        if currentToken == StepKeyword.self {
            return (title: title, description: nil)
        } else {
            return (title: title, description: try sentence())
        }
    }
    
    // @tag*
    private func tags() throws -> [ASTNode<Tag>] {
        var tagsList: [ASTNode<Tag>] = []
        
        while true {
            if
                let secondaryKeyword = currentToken.type as? SecondaryKeyword,
                case .tag(let name) = secondaryKeyword
            {
                let node = ASTNode(
                    Tag(tag: name),
                    location: currentToken.location
                )
                tagsList.append(node)
            } else {
                return tagsList
            }
            try eat()
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
    
    // tags -> SCENARIO KEY -> title_description -> steps -> examples
    private func scenario() throws -> ASTNode<Scenario>? {
        // tags
        let tagList: [ASTNode<Tag>]
        if tagsBuffer.isEmpty {
            tagList = try tags()
        } else {
            tagList = tagsBuffer
            tagsBuffer.removeAll()
        }
        
        // SCENARIO KEY
        guard currentToken.isScenarioKeyword else {
            if tagList.isEmpty {
                return nil
            }
            
            throw InterpreterException.unexpectedTerm(
                term: currentToken.type,
                expected: PrimaryKeyword.scenario // "Scenario:, Example:, Scenario Outline:, Scenario Template:"
            )
        }
        
        let location = currentToken.location
        let isOutline = currentToken.isScenarioOutlineKey

        try eat() // scenario key
        
        // title_description
        let titleDesc = try titleDescription()

        let scenario = Scenario(
            tags: tagList,
            title: titleDesc.title,
            description: titleDesc.description,
            steps: try steps(),
            outline: isOutline ? (try outline()) : .notOutline
        )
        
        return ASTNode(scenario, location: location)
    }
    
    // tags* -> (Examples -> DataTable)*
    private func outline() throws -> Outline {
        var exampleTables: [ASTNode<ExamplesTable>] = []
        
        while currentToken.isTagToken || currentToken.isExamplesToken {
            let tagList = try tags()
            
            if currentToken.isScenarioKeyword {
                tagsBuffer = tagList
                break
            }
            
            guard let exampleTable = try examples(tags: tagList) else {
                throw InterpreterException.scenarioOutlineWithoutExamples
            }
            
            exampleTables.append(exampleTable)
        }
        
        return Outline.outline(examples: exampleTables)
    }
    
    // Examples: -> title* -> columns_title -> data_table ->
    private func examples(tags: [ASTNode<Tag>]) throws -> ASTNode<ExamplesTable>? {
        // Examples:
        guard currentToken.isExamplesToken else {
            return nil
        }
        
        try eat()
        
        let location = currentToken.location
        
        let title = try sentence()
        
        // data table
        guard let table = try dataTable() else {
            throw InterpreterException.exampleTableWithoutRows
        }
        
        return ASTNode(try ExamplesTable(title: title, tags: tags, dataTable: table), location: location)
    }
    
    // PIPE -> (expression -> PIPE)* ->
    private func dataTable() throws -> ASTNode<DataTable>? {
        guard currentToken == SecondaryKeyword.pipe else {
            return nil
        }
        
        var rows: [ASTNode<DataTable.Row>] = []
        let location = currentToken.location
        
        // pipe
        try eat()
        
        while currentToken.isExpressionOrPipe {
            let initialLocation = currentToken.location
            var cells: [ASTNode<DataTable.Cell>] = []
            
            while currentToken.location.line == initialLocation.line && !(currentToken == EOF.self) {
                if currentToken.type is Expression {
                    let expression = currentToken
                    try eat()
                    
                    guard currentToken == SecondaryKeyword.pipe else {
                        throw InterpreterException.expectedDataTableToken
                    }
                    
                    let node = ASTNode(
                        DataTable.Cell.value((expression.type as! Expression).content),
                        location: expression.location
                    )
                    cells.append(node)
                } else if currentToken == SecondaryKeyword.pipe {
                    cells.append(ASTNode(DataTable.Cell.empty, location: currentToken.location))
                } else {
                    throw InterpreterException.expectedDataTableToken
                }
                
                try eat() // pipe
            }
            
            if currentToken.location.line != initialLocation.line && currentToken.type.isSameType(as: SecondaryKeyword.pipe) {
                try eat()
            }
            
            rows.append(ASTNode(DataTable.Row(cells: cells), location: initialLocation))
        }
        
        let dataTable = try DataTable(rows: rows)
        
        guard try DataTableValidator(mode: mode).validate(object: dataTable) else {
            throw InterpreterException.incorrectDataTable
        }
        
        return ASTNode(dataTable, location: location)
    }
    
    private func docString() throws -> ASTNode<DocString>? {
        guard let docStringToken = currentToken.type as? DocStringKeyword else {
            return nil
        }
        
        let initialLocation = currentToken.location
        try eat()
        
        var content = ""
        
        while currentToken.type is Expression || !currentToken.isDocStringOf(type: docStringToken.keyword) {
            if let expression = currentToken.type as? Expression {
                let leadingWhitespaces = max(currentToken.location.column - initialLocation.column, 0)
                content += repeatElement(" ", count: leadingWhitespaces) + expression.content
            } else if let keyword = currentToken.type as? DocStringKeyword {
                content += keyword.keyword.rawValue
            }
            
            try eat()
        }
        
        guard let docStringKeyword = currentToken.type as? DocStringKeyword else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: DocStringKeyword(mark: nil, keyword: .doubleQuotes))
        }
        
        try eat()
        
        let docString = DocString(
            mark: docStringToken.mark,
            content: content,
            delimiter: docStringKeyword.keyword
        )
        
        return ASTNode(docString, location: initialLocation)
    }
    
    private func steps() throws -> [ASTNode<Step>] {
        var stepList: [ASTNode<Step>] = []
        
        while currentToken.isStepKeyword {
            stepList.append(try step())
        }
        
        return stepList
    }
    
    // STEPKEYWORD -> step_text -> (data_table | doc_string)* ->
    private func step() throws -> ASTNode<Step> {
        guard let stepKeyword = currentToken.type as? StepKeyword else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: StepKeyword.given)
        }
        
        let stepLocation = currentToken.location
        try eat() // keyword
        
        guard let text = try sentence() else {
            throw InterpreterException.textExpectedNothingFound
        }
        
        let step = try Step(keyword: stepKeyword, text: text, docString: try docString(), dataTable: try dataTable())
        
        return ASTNode(step, location: stepLocation)
    }
}
