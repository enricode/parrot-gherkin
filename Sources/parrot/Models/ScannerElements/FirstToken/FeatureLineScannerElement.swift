import Foundation

struct FeatureLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    let tokens: [Token]
    
    static let typeIdentifier: String = "FeatureLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isFeatureKeyword else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
