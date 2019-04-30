import Foundation

struct TableRowScannerElement: ScannerElementDescriptor, ScannerElementLineTokenInitializable {
    
    let location: Location
    let items: [ScannerElementChildItem]
    
    static let typeIdentifier: String = "TableRow"
    
    init?(tokens: [Token]) {
        guard
            let firstToken = tokens.first, firstToken.isPipeKeyword,
            let lastToken = tokens.last, lastToken.isPipeKeyword
        else {
            return nil
        }
        
        location = firstToken.location
        
        let values = tokens.fillWithEmptyExpressionsBetweenDoublePipes()
        
        items = values.filter({ $0.isExpression }).map {
            ScannerElementChildItem(location: $0.location, value: $0.value ?? "")
        }
    }
}
