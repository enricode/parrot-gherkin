import Foundation

extension Character {
    var isSpace: Bool {
        return self == "\u{20}" || isTab
    }
    
    var isSlash: Bool {
        return self == "\\"
    }
    
    var isTab: Bool {
        return self == "\u{9}"
    }
    
    var isNewLine: Bool {
        return self == "\u{A}" || self == "\u{B}" || self == "\u{C}" || self == "\u{D}" || self == "\r\n"
    }
    
    var isTag: Bool {
        return self == "@"
    }
    
    var isColon: Bool {
        return self == ":"
    }
    
    var isPipe: Bool {
        return self == "|"
    }
    
    var isComment: Bool {
        return self == "#"
    }
    
    var isQuotes: Bool {
        return self == "\"" || self == "`"
    }
    
    var isNotSpace: Bool {
        return !isSpace && !isNewLine
    }
    
    var stringRepresentation: String {
        return String(self)
    }
}

extension String.SubSequence {
    
    var newLinesCount: Int {
        return filter({ $0.isNewLine }).count
    }
    
}
