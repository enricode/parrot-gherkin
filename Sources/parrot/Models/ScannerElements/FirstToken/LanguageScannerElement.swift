import Foundation

struct LanguageScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    let tokens: [Token]
    
    static let typeIdentifier: String = "Language"
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, case .language(let langId) = firstToken.type else {
            return nil
        }
        
        self.tokens = tokens
        location = firstToken.location
        text = langId
    }
}
