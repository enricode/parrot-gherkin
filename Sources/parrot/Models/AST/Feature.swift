import Foundation

enum FeatureInitializationException: String, ParrotError {
    case emptyTitle
    case emptyScenarios
    case emptyDescription
}

struct FeatureLanguage {
    let identifier: String
}

struct Feature: AST, Equatable {
    let tags: [ASTNode<Tag>]
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    let rules: [ASTNode<Rule>]
}
