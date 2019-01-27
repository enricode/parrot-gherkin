import Foundation

protocol TokenType {}

enum PrimaryKeyword: TokenType {
    case feature
    case rule
    
    case background
    
    case scenario
    case scenarioOutline
    
    case given
    case when
    case then
    case and
    case but
    
    case examples
}

enum SecondaryKeyword: TokenType {
    case docStrings
    case pipe
    case tag(value: String)
    case comment
}

struct Expression: TokenType {
    let content: String
}

struct EOF: TokenType {}
