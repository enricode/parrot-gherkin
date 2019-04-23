import Foundation

struct OtherScannerElement: ScannerElementDescriptor, ScannerElementLineTokenInitializable {
    let location: Location
    
    static let typeIdentifier: String = "Other"
    let text: String

    init?(tokens: [Token]) {
        guard let firstToken = tokens.first else {
            return nil
        }
        
        location = firstToken.location
        text = tokens.value
    }
}
