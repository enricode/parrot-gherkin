import Foundation

struct EOFScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "EOF"
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isEOF else {
            return nil
        }
        
        location = firstToken.location
    }
    
    var elementDescription: String {
        return "EOF"
    }
}
