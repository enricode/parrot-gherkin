import Foundation

struct DocString: AST, Equatable {
    let mark: String?
    let content: String?
    let delimiter: DocStringKeyword.Keyword
}
