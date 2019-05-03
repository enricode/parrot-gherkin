import Foundation

protocol ScannerError: Error, Locatable {
    var localizedDescription: String { get }
}

struct ScannerUnexpectedElement: ScannerError {
    let unexpected: ScannerElement
    let expected: [ScannerElement.Type]
    
    let location: Location
    
    init(unexpected: ScannerElement, expected: [ScannerElement.Type]) {
        self.unexpected = unexpected
        self.expected = expected
        
        location = unexpected.location
    }
    
    var localizedDescription: String {
        return "\(location.prettyPrint): expected: \(expected.prettyPrint), got '\(unexpected.prettyPrint)'"
    }
}

extension ScannerElement {
    
    var prettyPrint: String {
        return tokens.value
    }
    
}

extension Collection where Element == ScannerElement.Type {
    
    var prettyPrint: String {
        return map({ "#" + $0.typeIdentifier }).joined(separator: ", ")
    }
    
}

struct InconsistentCellCount: ScannerError {
    let location: Location
    
    var localizedDescription: String {
        return "\(location.prettyPrint): inconsistent cell count within the table"
    }
}

struct UnexpectedEndOfFile: ScannerError {
    let location: Location
    let expected: [ScannerElement.Type]
    
    var localizedDescription: String {
        return "\(location.prettyPrint): unexpected end of file, expected: \(expected.prettyPrint)"
    }
}
