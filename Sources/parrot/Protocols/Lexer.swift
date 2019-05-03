import Foundation

protocol Lexer {
    var text: String { get }
    var uri: URL? { get }
    
    func parse() throws -> [Token]
    func getNextToken() throws -> Token
}
