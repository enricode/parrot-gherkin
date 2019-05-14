import Foundation

enum FeatureInitializationException: String, ParrotError {
    case emptyTitle
    case emptyScenarios
    case emptyDescription
}

struct Feature: AST, Equatable {
    let language: String
    let tags: [ASTNode<Tag>]
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    let rules: [ASTNode<Rule>]
}
