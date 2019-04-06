import Foundation

struct Token {
    let type: TokenType
    let value: String?
    let location: Location
    
    init(_ type: TokenType, value: String? = nil, _ location: Location) {
        self.type = type
        self.value = value
        self.location = location
    }
    
    static func ==(lhs: Token, rhs: TokenType) -> Bool {
        return lhs.type == rhs
    }
}

extension Token {
    
    var isFeatureToken: Bool {
        return false
    }
    
}
