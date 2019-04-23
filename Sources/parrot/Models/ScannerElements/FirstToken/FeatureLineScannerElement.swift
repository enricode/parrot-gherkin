import Foundation

struct FeatureLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "FeatureLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isFeatureKeyword else {
            return nil
        }
        
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
