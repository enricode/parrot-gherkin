import Foundation

enum FeatureInitializationException: String, ParrotError {
    case emptyTitle
    case emptyScenarios
    case emptyDescription
}

enum FeatureLanguage: String {
    case english = "en"
}

struct Feature: AST, Equatable {
    let tags: [ASTNode<Tag>]
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    let rules: [ASTNode<Rule>]
    let language: FeatureLanguage = .english
}
