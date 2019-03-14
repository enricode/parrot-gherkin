import Foundation

enum InterpreterException: ParrotError {
    case unexpectedTerm(term: TokenType, expected: TokenType)
    case titleExpectedNothingFound
    case scenarioOutlineWithoutExamples
    case unexpectedTitleDescriptionFactor
    case exampleTableWithoutTitle
}

class CucumberInterpreter: Interpreter {    
    let lexer: Lexer
    
    private var currentToken: Token
    private var commentsTokens: [Token]
    
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
            
            if currentToken == Comment.self {
                commentsTokens.append(currentToken)
            }
        } while currentToken == Comment.self
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
        
        let table = try ExamplesTable(
            title: title,
            columns: try columnsTitles(),
            dataTable: try dataTable()
        )
        
        return ASTNode(table, location: location)
        
    }
    
    // (PIPE -> (word | whitespaces) * -> PIPE -> NEWLINE)* -> NEWLINE | Scenario Key ->
    private func dataTable() throws -> DataTable {
        var rows: [[String]] = []
        
        while currentToken == .pipe {
            rows.append(try wordsBetweenPipes())
        }
        
        return try DataTable(values: rows)
    }
    
    private func steps() throws -> [Step] {
        var stepList: [Step] = []
        
        while currentToken.isStepKeyword {
            stepList.append(try step())
        }
        
        return stepList
    }
    
    // STEPKEYWORD -> step_text -> (newline -> data_table | doc_string)* ->
    private func step() throws -> Step {
        // STEPKEYWORD
        guard case .stepKeyword(let keyword) = currentToken else {
            throw InterpreterException.unexpectedTerm(
                term: currentToken.descriptionValue,
                expected: Token.stepKeyword(.given).descriptionValue
            )
        }
        
        try eat() // keyword
        try eat() // whitespace
        
        // step_text
        let text = try stepText()
        
        // data_table
        var table: DataTable? = nil
        if currentToken == .newLine {
            try eat() // newline
            
            if currentToken == .pipe {
                table = try dataTable()
            }
        }
        
        return try Step(
            keyword: keyword.stepKeyword,
            text: text.content,
            parameters: text.parameters,
            dataTable: table
        )
    }
    
    private func stepText() throws -> (content: String, parameters: [Step.Parameter]) {
        var stepContent = ""
        var parameters: [Step.Parameter] = []
        
        while currentToken != .newLine && currentToken != .EOF {
            switch currentToken {
            case .exampleParameter(let value), .parameter(let value):
                let previousIndex = stepContent.endIndex
                let representation = currentToken.representation
                stepContent.append(representation)
                
                let closedRange = stepContent.index(after: previousIndex)...stepContent.index(before: stepContent.endIndex)
                let parameter = Step.Parameter(
                    kind: currentToken.isParameter ? .parameter : .example,
                    value: value,
                    position: closedRange
                )
                
                parameters.append(parameter)
            default:
                stepContent.append(currentToken.representation)
            }
            
            try eat()
        }
        
        return (stepContent, parameters)
    }
    
    private func columnsTitles() throws -> [String] {
        return try wordsBetweenPipes()
    }
    
    private func wordsBetweenPipes() throws -> [String] {
        guard currentToken == .pipe else {
            throw InterpreterException.unexpectedTerm(term: currentToken.representation, expected: Token.pipe.descriptionValue)
        }
        
        try eat() // ignore pipe
        
        var partialResult: String = ""
        var words: [String] = []
        
        while currentToken != .newLine && currentToken != .EOF {
            if currentToken == .pipe {
                words.append(partialResult.trimmingCharacters(in: .whitespaces))
                partialResult = ""
            } else {
                partialResult.append(currentToken.representation)
            }
            try eat()
        }
        
        try eat() // newLine
        
        return words
    }
    
    private func skipWhitespaces() throws {
        while currentToken.isWhitespace {
            try eat()
        }
    }
    
}
