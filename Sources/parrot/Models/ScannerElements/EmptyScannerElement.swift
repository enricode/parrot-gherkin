import Foundation

struct EmptyScannerElement: ScannerElementDescriptor {
    static let typeIdentifier: String = "Empty"
    
    let location: Location
    let keywordIdentifier: String = ""
    let text: String = ""
    let items: [ScannerElementChildItem] = []
}
