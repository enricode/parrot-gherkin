import Foundation

struct Location {
    let column: Int
    let line: Int
    
    func advancedBy(column: UInt = 0, line: UInt = 0) -> Location {
        return Location(column: self.column + Int(column), line: self.line + Int(line))
    }
}

struct Token {
    let type: TokenType
    let location: Location
    
    init(_ type: TokenType, _ location: Location) {
        self.type = type
        self.location = location
    }
}
