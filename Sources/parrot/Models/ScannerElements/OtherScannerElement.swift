import Foundation

struct OtherScannerElement: ScannerElementDescriptor, ScannerElementLineTokenInitializable {
    let location: Location
    let tokens: [Token]
    
    static let typeIdentifier: String = "Other"
    let text: String

    init(text: String, location: Location, tokens: [Token] = []) {
        self.text = text
        self.location = location
        self.tokens = tokens
    }
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first else {
            return nil
        }
        
        self.init(text: tokens.value.padded(leading: firstToken.location.column - 1),
                  location: firstToken.location.firstColumn,
                  tokens: tokens)
    }
}
