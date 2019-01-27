import Foundation

struct Location {
    let column: Int
    let line: Int
}

struct Token {
    let type: TokenType
    let location: Location
    
    init(_ type: TokenType, _ location: Location) {
        self.type = TokenType
        self.location = location
    }
}
