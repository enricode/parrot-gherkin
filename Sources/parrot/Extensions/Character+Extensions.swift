import Foundation

extension Character {
    var isSpace: Bool {
        return self == "\u{20}" || isTab
    }
    
    var isTab: Bool {
        return self == "\u{9}"
    }
    
    var isNewLine: Bool {
        return self == "\u{A}" || self == "\u{B}" || self == "\u{C}" || self == "\u{D}"
    }
    
    var isTagChar: Bool {
        return self == "@"
    }
    
    var isColon: Bool {
        return self == ":"
    }
    
    var isPipe: Bool {
        return self == "|"
    }
    
    var isCommentChar: Bool {
        return self == "#"
    }
    
    var isNotSpace: Bool {
        return !isSpace && !isNewLine
    }
}

extension String.SubSequence {
    
    var newLinesCount: Int {
        return filter({ $0.isNewLine }).count
    }
    
}
