import Foundation

enum LexerCharacter: Equatable, Hashable {
    case colon
    case comment
    case pipe
    case newLine
    case tab
    case tag
    case whitespace
    
    case generic(Character)
    case none
    
    init(char: Character?) {
        guard let char = char else {
            self = .none
            return
        }
        
        if char.isColon {
            self = .colon
        } else if char.isComment {
            self = .comment
        } else if char.isPipe {
            self = .pipe
        } else if char.isNewLine {
            self = .newLine
        } else if char.isTab {
            self = .tab
        } else if char.isTag {
            self = .tag
        } else if char.isSpace {
            self = .whitespace
        }
        
        self = .generic(char)
    }
    
    var representation: Character {
        switch self {
        case .colon: return ":"
        case .comment: return "#"
        case .pipe: return "|"
        case .newLine: return "\n"
        case .tab: return "\t"
        case .tag: return "@"
        case .whitespace: return " "
        case .generic(let value): return value
        case .none: return "\u{0}"
        }
    }
}
