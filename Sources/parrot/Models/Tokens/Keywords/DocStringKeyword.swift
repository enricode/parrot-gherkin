import Foundation

struct DocStringKeyword: GherkinKeyword, Equatable {
    static var keyCount: Int { return 3 }
    
    enum Keyword: String {
        case doubleQuotes = "\"\"\""
        case backticks = "```"
        
        init?(parsing: String) {
            if parsing.starts(with: Keyword.doubleQuotes.rawValue) {
                self = .doubleQuotes
                return
            }
            
            if parsing.starts(with: Keyword.backticks.rawValue) {
                self = .backticks
                return
            }
            
            return nil
        }
    }
    
    let mark: String?
    let keyword: Keyword
    
    var lenght: UInt {
        return UInt(DocStringKeyword.keyCount + (mark ?? "").count)
    }
}

