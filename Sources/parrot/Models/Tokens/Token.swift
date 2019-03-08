import Foundation

struct Location: Equatable {
    let column: Int
    let line: Int
    
    func advancedBy(column: UInt = 0, line: UInt = 0) -> Location {
        return Location(column: self.column + Int(column), line: self.line + Int(line))
    }
    
    static var start: Location = Location(column: 1, line: 1)
}

struct Token {
    let type: GherkinKeyword
    let location: Location
    
    init(_ type: GherkinKeyword, _ location: Location) {
        self.type = type
        self.location = location
    }
}
