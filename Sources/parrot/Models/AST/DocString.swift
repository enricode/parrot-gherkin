import Foundation

public struct DocString: AST, Equatable {
    let mark: String?
    let content: String?
    let delimiter: DocStringKeyword.Keyword
    
    public func export() -> [String : Any] {
        var docString: [String : Any] = [
            "delimiter": delimiter.rawValue
        ]
        
        if let content = content {
            docString["content"] = content
        }
        
        if let mark = mark {
            docString["contentType"] = mark
        }
        
        return docString
    }
}
