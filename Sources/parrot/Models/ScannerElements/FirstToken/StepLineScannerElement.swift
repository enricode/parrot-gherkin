import Foundation

struct StepLineScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "StepLine"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isStepKeyword else {
            return nil
        }
        
        location = firstToken.location
        keywordIdentifier = firstToken.value ?? ""
        text = tokens.valueExcludingFirst
    }
}
