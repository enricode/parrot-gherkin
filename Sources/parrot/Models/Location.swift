import Foundation

struct Location: Equatable {
    let column: Int
    let line: Int
    
    func advance() -> Location {
        return Location(column: self.column + 1, line: self.line)
    }
    
    static var start: Location = Location(column: 0, line: 1)
}
