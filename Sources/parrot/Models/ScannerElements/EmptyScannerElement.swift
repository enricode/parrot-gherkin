import Foundation

struct EmptyScannerElement: ScannerElement, ScannerElementDescriptor {
    let tokens: [Token] = []
    
    static let typeIdentifier: String = "Empty"
    
    let location: Location
    let keywordIdentifier: String = ""
    let text: String = ""
    let items: [ScannerElementChildItem] = []
}
