import Foundation

struct TagLineScannerElement: ScannerElementDescriptor, ScannerElementLineTokenInitializable {
    let tokens: [Token]
    let location: Location
    let items: [ScannerElementChildItem]

    static let typeIdentifier: String = "TagLine"
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isTagToken else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location
        items = tokens.filter({ $0.isTagToken }).map {
            ScannerElementChildItem(location: $0.location, value: $0.value ?? "")
        }
    }
}
