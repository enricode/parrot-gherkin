import Foundation

enum TokenType: Equatable {
    case comment(String)
    case eof
    case expression
    case keyword(GherkinKeyword)
    case language(String)
    
    static func ==(lhs: TokenType, rhs: TokenType) -> Bool {
        switch (lhs, rhs) {
        case (.keyword(let key1), .keyword(let key2)):
            return String(describing: key1) == String(describing: key2)
        case (.expression, .expression), (.eof, .eof), (.comment, .comment), (.language, .language):
            return true
        default:
            return false
        }
    }
}
