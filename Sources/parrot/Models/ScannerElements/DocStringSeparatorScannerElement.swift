import Foundation

struct DocStringSeparatorScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "DocStringSeparator"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let token = tokens.first, let docString = token.keyword as? DocStringKeyword, tokens.count == 1 else {
            return nil
        }
        
        location = token.location
        keywordIdentifier = docString.keyword.rawValue
        text = docString.mark ?? ""
    }
}
