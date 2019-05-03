import Foundation

struct ScenarioLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "ScenarioLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isScenarioKeyword else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
