import Foundation

protocol TokenType {
    var keyword: String? { get }
}

extension TokenType {
    var keyword: String? {
        return nil
    }
}

enum PrimaryKeyword: String, CaseIterable, TokenType {
    case feature = "Feature"
    case rule = "Rule"
    
    case background = "Background"
    
    case scenario = "Scenario"
    case scenarioOutline = "Scenario Outline"
    
    case given = "Given"
    case when = "When"
    case then = "Then"
    case and = "And"
    case but = "But"
    
    case examples = "Examples"
    
    var keyword: String? {
        return rawValue //TODO: multiple languages
    }
}

enum SecondaryKeyword: TokenType {   
    case comment
    case docStrings(mark: String?)
    case pipe
    case tag(value: String)
}

struct Expression: TokenType {
    let content: String
}

struct EOF: TokenType {}
