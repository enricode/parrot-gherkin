import Foundation

protocol Lexer {
    var text: String { get }
    
    func parse() throws -> [Token]
    func getNextToken() throws -> Token
}
