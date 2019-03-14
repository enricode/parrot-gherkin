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
}

class CucumberInterpreter: Interpreter {    
    
    let lexer: Lexer
    
    private var currentToken: Token
    private var commentsTokens: [Token] = []
    
    init(lexer: Lexer) throws {
        self.lexer = lexer
        currentToken = try lexer.getNextToken()
    }
    
    func parse() throws -> ASTNode<Feature> {
        return try feature()
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
    private func feature() throws -> ASTNode<Feature> {
        let tagList = try tags()
        
        guard currentToken == PrimaryKeyword.feature else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: PrimaryKeyword.feature)
        }
        
        let featureLocation = currentToken.location
        try eat() // Feature token
        
        let titleDesc = try titleDescription()
        let scenarioList = try scenarios()
        
        guard currentToken == EOF.self else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: EOF())
        }
        
        return ASTNode(
            try Feature(
                tags: tagList,
                title: titleDesc.title,
                description: titleDesc.description,
                scenarios: scenarioList
            ),
            location: featureLocation
        )
    }
    
    private func sentence() -> String? {
        guard let expressionToken = currentToken.type as? Expression else {
            return nil
        }
        
        return expressionToken.content
    }
    
    private func titleDescription() throws -> (title: String, description: String?) {
        guard let title = sentence() else {
            throw InterpreterException.titleExpectedNothingFound
        }
        
        if currentToken == StepKeyword.self {
            return (title: title, description: nil)
        } else {
            return (title: title, description: sentence())
        }
    }
    
    // @tag*
    private func tags() throws -> [ASTNode<Tag>] {
        var tags: [ASTNode<Tag>] = []
        
        while true {
            if let secondaryKeyword = currentToken.type as? SecondaryKeyword,
                case .tag(let name) = secondaryKeyword
            {
                let node = ASTNode(
                    Tag(tag: name),
                    location: currentToken.location
                )
                tags.append(node)
            } else {
                return tags
            }
            try eat()
        }
        
        return tags
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
        let tagList = try tags()
        
        // SCENARIO KEY
        guard currentToken.isScenarioKeyword else {
            throw InterpreterException.unexpectedTerm(
                term: currentToken.type,
                expected: PrimaryKeyword.scenario // "Scenario:, Example:, Scenario Outline:, Scenario Template:"
            )
        }
        let location = currentToken.location

        try eat() // scenario key
        
        // title_description
        let titleDesc = try titleDescription()

        let scenario = try Scenario(
            tags: tagList,
            title: titleDesc.title,
            description: titleDesc.description,
            steps: try steps(),
            outline: try outline()
        )
        
        return ASTNode(scenario, location: location)
    }
    
    private func outline() throws -> Outline {
        if currentToken.isScenarioOutlineKey {
            guard let exampleTable = try examples() else {
                throw InterpreterException.scenarioOutlineWithoutExamples
            }
            return Outline.outline(examples: exampleTable)
        } else {
            return Outline.notOutline
        }
    }
    
    // Examples: -> title -> columns_title -> data_table ->
    private func examples() throws -> ASTNode<ExamplesTable>? {
        // Examples:
        guard currentToken.isExamplesToken else {
            return nil
        }
        
        let location = currentToken.location
        
        // title
        guard let title = sentence() else {
            throw InterpreterException.exampleTableWithoutTitle
        }
        
        // data table
        guard let table = try dataTable() else {
            throw InterpreterException.exampleTableWithoutRows
        }
        
        return ASTNode(try ExamplesTable(title: title, dataTable: table), location: location)
    }
    
    // PIPE -> (expression -> PIPE)* ->
    private func dataTable() throws -> DataTable? {
        guard currentToken == SecondaryKeyword.pipe else {
            return nil
        }
        
        var rows: [ASTNode<DataTable.Row>] = []
        
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
            
            rows.append(ASTNode(DataTable.Row(cells: cells), location: initialLocation))
        }
        
        return try DataTable(rows: rows)
    }
    
    private func steps() throws -> [ASTNode<Step>] {
        var stepList: [ASTNode<Step>] = []
        
        while currentToken.isStepKeyword {
            stepList.append(try step())
        }
        
        return stepList
    }
    
    // STEPKEYWORD -> step_text -> (newline -> data_table | doc_string)* ->
    private func step() throws -> ASTNode<Step> {
        guard let stepKeyword = currentToken.type as? StepKeyword else {
            throw InterpreterException.unexpectedTerm(term: currentToken.type, expected: StepKeyword.given)
        }
        
        let stepLocation = currentToken.location
        try eat() // keyword
        
        guard let text = sentence() else {
            throw InterpreterException.textExpectedNothingFound
        }
        
        let step = try Step(keyword: stepKeyword, text: text, dataTable: try dataTable())
        
        return ASTNode(step, location: stepLocation)
    }
}
