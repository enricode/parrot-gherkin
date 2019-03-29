import Foundation

enum ScenarioInitializationException: String, ParrotError {
    case emptyTitle
    case emptyDescription
    case emptySteps
    case noStepsFound
}

struct Scenario: AST, Equatable {
    let tags: [ASTNode<Tag>]
    let title: String?
    let description: String?
    let steps: [ASTNode<Step>]
    let isOutline: Bool
    let examples: [ASTNode<ExamplesTable>]
}
