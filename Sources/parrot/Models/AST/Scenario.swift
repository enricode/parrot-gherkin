import Foundation

enum ScenarioInitializationException: String, ParrotError {
    case emptyTitle
    case emptyDescription
    case emptySteps
    case noStepsFound
}

enum Outline: Equatable {
    case notOutline
    case outline(examples: [ASTNode<ExamplesTable>])
}

struct Scenario: AST, Equatable {
    let tags: [ASTNode<Tag>]
    let title: String?
    let description: String?
    let steps: [ASTNode<Step>]
    let outline: Outline
}
