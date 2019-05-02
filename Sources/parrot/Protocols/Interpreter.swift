import Foundation

protocol Interpreter {
    associatedtype RootNode: AST & Equatable
    
    var scanner: Scanner { get }
    func parse() throws -> ASTNode<RootNode>?
}
