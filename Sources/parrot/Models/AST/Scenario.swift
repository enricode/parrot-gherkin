import Foundation

public enum ScenarioInitializationException: String, ParrotError {
    case emptyTitle
    case emptyDescription
    case emptySteps
    case noStepsFound
}

public struct Scenario: AST, Equatable {
    let tags: [ASTNode<Tag>]
    let keyword: String
    let title: String?
    let description: String?
    let steps: [ASTNode<Step>]
    let isOutline: Bool
    let examples: [ASTNode<ExamplesTable>]
    
    public func export() -> [String : Any] {
        var scenario: [String : Any] = [
            "keyword": keyword
        ]
        
        if let title = title {
            scenario["name"] = title
        }
        
        if !tags.isEmpty {
            scenario["tags"] = tags.export()
        }
        
        if let description = description {
            scenario["description"] = description
        }
        
        if !steps.isEmpty {
            scenario["steps"] = steps.export()
        }
        
        if !examples.isEmpty {
            scenario["examples"] = examples.export()
        }
        
        return scenario
    }
}
