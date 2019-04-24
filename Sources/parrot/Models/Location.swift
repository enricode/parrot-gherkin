import Foundation

struct Location: Equatable {
    let column: Int
    let line: Int
    
    static var start: Location = Location(column: 0, line: 1)
    
    var resettingColumn: Location {
        return Location(column: 1, line: line)
    }
    
    var previous: Location? {
        guard column > 1 else {
            return nil
        }
        return Location(column: column - 1, line: line)
    }
    
    func with(offset: Int) -> Location {
        return Location(column: max(1, column - offset + 1), line: line)
    }
    
    func advance() -> Location {
        return Location(column: self.column + 1, line: self.line)
    }
}
