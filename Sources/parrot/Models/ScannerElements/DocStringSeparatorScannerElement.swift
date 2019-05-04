import Foundation

struct DocStringSeparatorScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "DocStringSeparator"
    let keywordIdentifier: String
    let text: String
    
    let mark: String?
    let delimiter: DocStringKeyword.Keyword
    
    init?(tokens: [Token]) {
        guard let token = tokens.first, let docString = token.keyword as? DocStringKeyword, tokens.count == 1 else {
            return nil
        }
        
        self.tokens = tokens
        
        delimiter = docString.keyword
        mark = docString.mark
        
        location = token.location
        keywordIdentifier = docString.keyword.rawValue
        text = docString.mark ?? ""
    }
}
