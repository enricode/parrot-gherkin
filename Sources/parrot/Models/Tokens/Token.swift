import Foundation

struct Location: Equatable {
    let column: Int
    let line: Int
    
    func advance() -> Location {
        return Location(column: self.column + 1, line: self.line)
    }
    
    static var start: Location = Location(column: 0, line: 1)
}

protocol TokenType {
    func isSameType(as object: Any) -> Bool
}

extension TokenType {
    
    func isSameType(as object: Any) -> Bool {
        return object is Self
    }
    
}

extension TokenType where Self: RawRepresentable, Self.RawValue == String {
    
    func isSameType(as object: Any) -> Bool {
        guard let other = object as? Self else {
            return false
        }
        
        return other.rawValue == rawValue
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

extension Token {
    
    static func ==(lhs: Token, rhs: TokenType) -> Bool {
        return lhs.type.isSameType(as: rhs)
    }
    
    static func ==<T: TokenType>(lhs: Token, rhs: T.Type) -> Bool {
        return lhs.type.isSameType(as: rhs)
    }
    
}
