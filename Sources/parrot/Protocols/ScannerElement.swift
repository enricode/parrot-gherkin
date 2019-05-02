import Foundation

protocol ScannerElementLineTokenInitializable: ScannerElement {
    init?(tokens: [Token])
}

struct ScannerElementChildItem {
    let location: Location
    let value: String
    
    var elementDescription: String {
        return "\(location.column):\(value)"
    }
}

protocol ScannerElementDescriptor {
    static var typeIdentifier: String { get }
    
    var location: Location { get }
    var keywordIdentifier: String { get }
    var text: String { get }
    var items: [ScannerElementChildItem] { get }
    var elementDescription: String { get }
}

extension ScannerElementDescriptor {
    
    var elementDescription: String {
        let outputPieces: [String] = [
            "(",
            String(location.line),
            ":",
            String(location.column),
            ")",
            Self.typeIdentifier,
            ":",
            keywordIdentifier,
            "/",
            text,
            "/",
            items.elementDescription
        ]
        
        return outputPieces.joined(separator: "")
    }

}

extension ScannerElementLineTokenInitializable where Self: ScannerElementDescriptor {
    var keywordIdentifier: String {
        return ""
    }
    
    var text: String {
        return ""
    }
    
    var items: [ScannerElementChildItem] {
        return []
    }
}

extension Collection where Element == ScannerElementChildItem {
    
    var elementDescription: String {
        let line = map { "\($0.location.column):\($0.value)" }
        return line.joined(separator: ",")
    }
    
}
