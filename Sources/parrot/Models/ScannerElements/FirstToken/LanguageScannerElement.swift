import Foundation

struct LanguageScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let location: Location
    
    static let typeIdentifier: String = "Language"
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, case .language(let langId) = firstToken.type else {
            return nil
        }
        
        location = Location(column: 1, line: firstToken.location.line)
        text = langId
    }
}
