import Foundation

struct Rule: AST, Equatable {
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
}
