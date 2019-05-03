import Foundation

struct RuleLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    var tokens: [Token]
    
    let location: Location
    
    static let typeIdentifier: String = "RuleLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isRuleKeyword else {
            return nil
        }
        
        self.tokens = tokens
        
        location = firstToken.location
        keywordIdentifier = firstToken.value?.removingColon ?? ""
        text = tokens.valueExcludingFirst
    }
}
