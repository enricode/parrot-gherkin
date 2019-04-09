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
    
    let lexer: Lexer
    
    private var currentToken: Token
    private var tagsBuffer: [ASTNode<Tag>] = []
    private(set) var commentsTokens: [Token] = []
    
    init(lexer: Lexer) throws {
        self.lexer = lexer

        currentToken = try lexer.getNextToken()
    }
    
    func parse() throws -> ASTNode<Feature>? {
        let parsedFeature = try feature()
        
        /*if let feature = parsedFeature {
            let validFeature = try FeatureValidator(mode: mode).validate(object: feature.element)
            
            guard validFeature else {
                throw InterpreterException.cannotParseFeature
            }
        }*/
        
        return parsedFeature
    }
    
    private func eat() throws {
        repeat {
            currentToken = try lexer.getNextToken()

            if currentToken.isComment {
                commentsTokens.append(currentToken)
                try eat()
            }
        } while currentToken.isComment
    }
    
    // tags -> FEATURE: -> title_description -> scenarios -> EOF
    private func feature() throws -> ASTNode<Feature>? {
        let tagList = try tags()
        
        guard currentToken.isFeatureKeyword else {
            if currentToken == .eof {
                return nil
            }
            if commentsTokens.isEmpty && !currentToken.isComment {
                throw InterpreterException.cannotParseFeature
            }
            return nil
        }
        
        let featureLocation = currentToken.location
        try eat() // Feature token
        
        let titleDesc = try titleDescription()
        let scenarioList = try scenarios()
        let ruleList = try rules()
        
        guard currentToken.isEOF else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: .eof)
        }
        
        return ASTNode(
            Feature(
                tags: tagList,
                title: titleDesc.title,
                description: titleDesc.description,
                scenarios: scenarioList,
                rules: ruleList
            ),
            location: featureLocation
        )
    }
    
    private func sentences() throws -> String? {
        guard currentToken.isExpression else {
            return nil
        }
        
        var content = ""
        
        while currentToken.isExpression {
            content.append((currentToken.value ?? "") + " ")
            try eat()
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func sentence() throws -> String? {
        guard currentToken.isExpression, let value = currentToken.value else {
            return nil
        }
        
        try eat()
        
        return value
    }
    
    private func titleDescription() throws -> (title: String?, description: String?) {
        let title = try sentence()
        
        if currentToken.isStepKeyword {
            return (title: title, description: nil)
        } else {
            return (title: title, description: try sentences())
        }
    }
    
    // @tag*
    private func tags() throws -> [ASTNode<Tag>] {
        var tagsList: [ASTNode<Tag>] = []
        
        while true {
            if
                case .keyword(let keyword) = currentToken.type,
                let secondaryKey = keyword as? SecondaryKeyword,
                case .tag(let name) = secondaryKey
            {
                let node = ASTNode(Tag(tag: name), location: currentToken.location)
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

    private func rules() throws -> [ASTNode<Rule>] {
        var ruleList: [ASTNode<Rule>] = []
        
        while let rule = try rule() {
            ruleList.append(rule)
        }
        
        return ruleList
    }
    
    private func rule() throws -> ASTNode<Rule>? {
        guard currentToken.isRuleKeyword else {
            return nil
        }
        
        let location = currentToken.location
        try eat()
        
        let titleDesc = try titleDescription()
        
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
                expected: .keyword(PrimaryKeyword.scenario) // "Scenario:, Example:, Scenario Outline:, Scenario Template:"
            )
        }
        
        let location = currentToken.location
        let isOutline = currentToken.isScenarioOutlineKeyword

        try eat() // scenario key
        
        // title_description
        let titleDesc = try titleDescription()

        let scenario = Scenario(
            tags: tagList,
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
        
        while currentToken.isTagToken || currentToken.isExamplesToken {
            let tagList = try tags()
            
            if currentToken.isScenarioKeyword {
                tagsBuffer = tagList
                break
            }
            
            if let exampleTable = try examples(tags: tagList) {
                exampleTables.append(exampleTable)
            }
        }
        
        return exampleTables
    }
    
    // Examples: -> title* -> columns_title -> data_table ->
    private func examples(tags: [ASTNode<Tag>]) throws -> ASTNode<ExamplesTable>? {
        // Examples:
        guard currentToken.isExamplesToken else {
            return nil
        }
        
        try eat()
        
        let location = currentToken.location
        let titleDesc = try titleDescription()
        
        let examplesTable = try ExamplesTable(
            title: titleDesc.title,
            description: titleDesc.description,
            tags: tags,
            dataTable: try dataTable()
        )
        
        return ASTNode(examplesTable, location: location)
    }
    
    // PIPE -> (expression -> PIPE)* ->
    private func dataTable() throws -> ASTNode<DataTable>? {
        guard currentToken.isPipeKeyword else {
            return nil
        }
        
        var rows: [ASTNode<DataTable.Row>] = []
        let location = currentToken.location
        
        // pipe
        try eat()
        
        while currentToken.isPipeKeyword || currentToken.isExpression {
            let initialLocation = currentToken.location
            var cells: [ASTNode<DataTable.Cell>] = []
            
            while currentToken.location.line == initialLocation.line && !currentToken.isEOF {
                if currentToken.type == .expression {
                    let location = currentToken.location
                    try eat()
                    
                    guard currentToken.isPipeKeyword else {
                        throw InterpreterException.expectedDataTableToken
                    }
                    
                    let node = ASTNode(
                        DataTable.Cell.value(currentToken.value ?? ""),
                        location: location
                    )
                    cells.append(node)
                } else if currentToken.isPipeKeyword {
                    cells.append(ASTNode(DataTable.Cell.empty, location: currentToken.location))
                } else if currentToken.isEOF {
                    break
                } else {
                    throw InterpreterException.expectedDataTableToken
                }
                
                try eat() // pipe
            }
            
            if currentToken.location.line != initialLocation.line && currentToken.isPipeKeyword {
                try eat()
            }
            
            rows.append(ASTNode(DataTable.Row(cells: cells), location: initialLocation))
        }
        
        let dataTable = try DataTable(rows: rows)
        
        return ASTNode(dataTable, location: location)
    }
    
    private func docString() throws -> ASTNode<DocString>? {
        guard case .keyword(let docStringToken) = currentToken.type, let docStringKeyword = docStringToken as? DocStringKeyword else {
            return nil
        }
        
        let initialLocation = currentToken.location
        try eat()
        
        var content = ""
        
        while currentToken.isExpression || !currentToken.isDocStringOf(type: docStringKeyword.keyword) {
            if currentToken.isExpression {
                let leadingWhitespaces = max(currentToken.location.column - initialLocation.column, 0)
                content += repeatElement(" ", count: leadingWhitespaces) + (currentToken.value ?? "")
            } else if currentToken.isDocStringKeyword, let additionalContent = currentToken.value {
                content += additionalContent
            }
            
            try eat()
        }
        
        guard currentToken.isDocStringKeyword else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: .keyword(docStringKeyword))
        }
        
        try eat()
        
        let docString = DocString(
            mark: docStringKeyword.mark,
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
        guard case .keyword(let stepToken) = currentToken.type, let stepKeyword = stepToken as? StepKeyword else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: .keyword(StepKeyword.given))
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
