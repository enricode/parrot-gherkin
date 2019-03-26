import Foundation

protocol Interpreter {
    associatedtype RootNode: AST & Equatable
    
    var lexer: Lexer { get }
    func parse() throws -> ASTNode<RootNode>?
}
