//
//  Interpreter.swift
//  parrot
//
//  Created by Enrico Franzelli on 29/12/18.
//

import Foundation

enum InterpreterException: ParrotError {
    case unexpectedTerm(term: String, expected: String)
    case titleExpectedNothingFound
    case scenarioOutlineWithoutExamples
    case unexpectedTitleDescriptionFactor
    case exampleTableWithoutTitle
}

class CucumberInterpreter: Interpreter {    
    let lexer: Lexer
    
    private var fileLine: Int = 0
    private var currentToken: Token = .EOF
    private var currentLine: Int = 0
    
    init(lexer: Lexer) throws {
        self.lexer = lexer
    }
    
    func parse() throws -> AST {
        return try feature()
    }
    
    @discardableResult
    private func eat() throws -> Token {
        currentToken = try lexer.getNextToken()
        
        if currentToken == .newLine {
            fileLine += 1
        }
        
        return currentToken
    }
    
    private func sentence() throws -> String? {
        var result = ""
        while currentToken != .newLine && currentToken != .EOF {
            result.append(currentToken.representation)
            try eat()
        }
        return result == "" ? nil : result
    }
    
    // tags -> NL -> FEATURE: -> title_description -> scenarios -> EOF
    private func feature() throws -> Feature {
        let tagList = try tags()
        
        if !tagList.isEmpty && currentToken != .newLine {
            throw InterpreterException.unexpectedTerm(term: currentToken.descriptionValue, expected: Token.newLine.descriptionValue)
        }
        
        guard try eat() == Token.scenarioKey(.feature) else {
            throw InterpreterException.unexpectedTerm(term: currentToken.descriptionValue, expected: ScenarioKey.feature.descriptionValue)
        }
        
        let titleDesc = try titleDescription(factor: ScenarioKey.feature)
        let scenarioList = try scenarios()
        
        try ensureResidualTokensAreWhitespacesAndNewlines()
        
        return try Feature(
            tags: tagList,
            title: titleDesc.title,
            description: titleDesc.description,
            scenarios: scenarioList
        )
    }
    
    private func titleDescription(factor: Keyword) throws -> (title: String, description: String?) {
        guard let title = try sentence() else {
            throw InterpreterException.titleExpectedNothingFound
        }
        try eat()
        
        if factor is ScenarioKey, currentToken.isScenarioKeyword {
            return (title: title, description: nil)
        }
        
        if factor is StepKeyword, currentToken.isStepKeyword {
            return (title: title, description: nil)
        }
        
        if !(factor is ScenarioKey || factor is StepKeyword) {
            throw InterpreterException.unexpectedTitleDescriptionFactor
        }
        
        return (title: title, description: try sentence())
    }
    
    // @tag*
    private func tags() throws -> [Tag] {
        var tags: [Tag] = []
        
        while case .tag(let tagValue) = currentToken {
            tags.append(Tag(tag: tagValue))
            try eat()
        }
        
        return tags
    }
    
    // scenario | scenario*
    private func scenarios() throws -> [Scenario] {
        var scenarioList: [Scenario] = []
        
        while let scenario = try scenario() {
            scenarioList.append(scenario)
        }
        
        return scenarioList
    }
    
    // tags -> SCENARIO KEY -> title_description -> steps -> examples
    private func scenario() throws -> Scenario? {
        // tags
        let tagList = try tags()
        
        // SCENARIO KEY
        guard case .scenarioKey(let scenarioKey) = currentToken else {
            throw InterpreterException.unexpectedTerm(term: currentToken.descriptionValue, expected: "Scenario:, Example:, Scenario Outline:, Scenario Template:")
        }
        
        // title_description
        let titleDesc = try titleDescription(factor: ScenarioKey.scenario)
        
        // steps
        let stepList = try steps()
        
        // outline
        let outline: Outline
        if scenarioKey.isScenarioOutlineKey {
            guard let exampleTable = try examples() else {
                throw InterpreterException.scenarioOutlineWithoutExamples
            }
            outline = Outline.outline(examples: exampleTable)
        } else {
            outline = Outline.notOutline
        }
        
        return try Scenario(
            tags: tagList,
            title: titleDesc.title,
            description: titleDesc.description,
            steps: stepList,
            outline: outline
        )
    }
    
    // Examples: -> title -> columns_title -> data_table ->
    private func examples() throws -> ExamplesTable? {
        // Examples:
        guard currentToken.isExamplesToken else {
            return nil
        }
        
        // title
        guard let title = try sentence() else {
            throw InterpreterException.exampleTableWithoutTitle
        }
        
        // columns_title
        let columns = try columnsTitles()
        
        // data_table
        let exampleTable = try dataTable()
        
        return try ExamplesTable(
            title: title,
            columns: columns,
            dataTable: exampleTable
        )
    }
    
    // (PIPE -> (word | whitespaces) * -> PIPE -> NEWLINE)* -> NEWLINE | Scenario Key ->
    private func dataTable() throws -> DataTable {
        var rows: [[String]] = []
        
        while currentToken == .pipe {
            rows.append(try wordsBetweenPipes())
            
            if currentToken != .EOF {
                try eat() // eat newline
            }
        }
        
        return try DataTable(values: rows)
    }
    
    private func steps() throws -> [Step] {
        return []
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
        
        return words
    }
    
    private func skipWhitespaces() throws {
        while currentToken.isWhitespace {
            try eat()
        }
    }
    
    private func ensureResidualTokensAreWhitespacesAndNewlines() throws {
        guard currentToken != .EOF else {
            return
        }
        
        try eat()
        while currentToken.isWhitespaceOrNewLine {
            try eat()
        }
        
        if currentToken != .EOF {
            throw InterpreterException.unexpectedTerm(term: currentToken.descriptionValue, expected: Token.EOF.descriptionValue)
        }
    }
    
}

extension Token {
    
    var isTag: Bool {
        if case .tag(_) = self {
            return true
        }
        return false
    }
    
    var isScenarioKeyword: Bool {
        if case .scenarioKey(_) = self {
            return true
        }
        return false
    }
    
    var isStepKeyword: Bool {
        if case .stepKeyword(_) = self {
            return true
        }
        return false
    }
    
    var isExamplesToken: Bool {
        if case .scenarioKey(let key) = self, key == .examples {
            return true
        }
        return false
    }
    
    var isWhitespace: Bool {
        if case .whitespaces(_) = self {
            return true
        }
        return false
    }
    
    var isWhitespaceOrNewLine: Bool {
        switch self {
        case .whitespaces, .newLine:
            return true
        default:
            return false
        }
    }
    
    var descriptionValue: String {
        switch self {
        case .colon: return ":"
        case .exampleParameter: return "<parameter>"
        case .newLine: return "newline"
        case .parameter: return "\"parameter\""
        case .pipe: return "|"
        case .scenarioKey: return "Scenario:, Example:, Examples:, Feature:, Outline:, Template:, Background:"
        case .stepKeyword: return "Given, When, Then, And, But"
        case .tag: return "@tag"
        case .whitespaces: return "'whitespace'"
        case .word(let value): return "word '\(value)'"
        case .EOF: return "end of file"
        }
    }
    
}

extension ScenarioKey {
    
    fileprivate var descriptionValue: String {
        return rawValue
    }
    
}

extension StepKeyword {
    
    fileprivate var descriptionValue: String {
        return rawValue
    }
    
}
