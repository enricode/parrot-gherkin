import Foundation

struct StepLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "StepLine"
    let keyword: StepKeyword
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard
            let firstToken = tokens.first,
            case .keyword(let keyword) = firstToken.type,
            let stepKeyword = keyword as? StepKeyword
        else {
            return nil
        }
        
        self.tokens = tokens
        self.keyword = stepKeyword
        
        location = firstToken.location
        keywordIdentifier = firstToken.value ?? ""
        text = tokens.valueExcludingFirst
    }
}
