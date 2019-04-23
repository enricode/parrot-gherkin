import Foundation

struct TableRowScannerElement: ScannerElementDescriptor, ScannerElementLineTokenInitializable {
    
    let location: Location
    let items: [ScannerElementChildItem]
    
    static let typeIdentifier: String = "TableRow"
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isPipeKeyword else {
            return nil
        }
        
        location = firstToken.location
        items = tokens.filter({ $0.isExpression }).map {
            ScannerElementChildItem(location: $0.location, value: $0.value ?? "")
        }
    }
}