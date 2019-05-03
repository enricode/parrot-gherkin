import Foundation

struct EOFScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "EOF"
    
    init(location: Location) {
        self.location = location.zeroingColumn
        tokens = []
    }
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isEOF else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location.zeroingColumn
    }
    
    var elementDescription: String {
        return "EOF"
    }
}
