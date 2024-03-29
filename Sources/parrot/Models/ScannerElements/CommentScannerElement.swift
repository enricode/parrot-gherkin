import Foundation

struct CommentScannerElement: ScannerElementLineTokenInitializable, ScannerElementDescriptor {
    let tokens: [Token]
    let location: Location
    
    static let typeIdentifier: String = "Comment"
    let keywordIdentifier: String
    let text: String
    
    init?(tokens: [Token]) {
        guard let firstToken = tokens.first, firstToken.isComment else {
            return nil
        }
        
        self.tokens = tokens
        location = Location(column: 1, line: firstToken.location.line)
        keywordIdentifier = ""
        text = tokens.value
    }
}
