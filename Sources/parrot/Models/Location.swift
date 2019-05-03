import Foundation

struct Location: Equatable, Codable {
    let column: Int
    let line: Int
    
    static var start: Location = Location(column: 0, line: 1)
    
    var firstColumn: Location {
        return Location(column: 1, line: line)
    }
    
    var zeroingColumn: Location {
        return Location(column: 0, line: line)
    }
    
    var previous: Location? {
        guard column > 1 else {
            return nil
        }
        return Location(column: column - 1, line: line)
    }
    
    var prettyPrint: String {
        return "(\(line):\(column))"
    }
    
    var newLine: Location {
        return Location(column: 0, line: line + 1)
    }
    
    func with(offset: Int) -> Location {
        return Location(column: max(1, column - offset + 1), line: line)
    }
    
    func advance() -> Location {
        return Location(column: self.column + 1, line: self.line)
    }
    
    init(column: Int, line: Int) {
        self.column = column
        self.line = line
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        line = try container.decode(Int.self, forKey: .line)
        column = try container.decodeIfPresent(Int.self, forKey: .column) ?? 0
    }

}
