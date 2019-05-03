import Foundation

struct BackgroundLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "BackgroundLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.type == PrimaryKeyword.background else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
