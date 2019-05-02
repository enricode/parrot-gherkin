import Foundation

struct ScenarioLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor, FirstLevelScannerElement {
    let location: Location
    
    static let typeIdentifier: String = "ScenarioLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isScenarioKeyword else {
            return nil
        }
        
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
