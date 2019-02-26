import Foundation

protocol Interpreter {
    var lexer: Lexer { get }
    func parse() throws -> AST
}
