import Foundation

struct ParseError: Error {
    private(set) var errors: [ExportableError] = []
    
    mutating func add(error: ExportableError) {
        errors.append(error)
    }
    
    var hasNoErrors: Bool {
        return errors.isEmpty
    }
}
