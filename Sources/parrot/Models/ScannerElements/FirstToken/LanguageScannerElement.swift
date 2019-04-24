import Foundation

struct LanguageScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "Language"
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, case .language(let langId) = firstToken.type else {
            return nil
        }
        
        location = firstToken.location
        text = langId
    }
}
