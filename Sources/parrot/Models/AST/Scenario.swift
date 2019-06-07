import Foundation

public enum ScenarioInitializationException: String, ParrotError {
    case emptyTitle
    case emptyDescription
    case emptySteps
    case noStepsFound
}

public struct Scenario: AST, Equatable {
    
    enum KeywordType: String, Keyword, Equatable {
        case scenario
        case background
    }
    
    let tags: [ASTNode<Tag>]
    let keyword: KeywordPair<KeywordType>
    let title: String?
    let description: String?
    let steps: [ASTNode<Step>]
    let isOutline: Bool
    let examples: [ASTNode<ExamplesTable>]
    
    public func export() -> [String : Any] {
        var scenario: [String : Any] = [
            "keyword": keyword.keyword
        ]
        
        if let title = title, !title.isEmpty {
            scenario["name"] = title
        }
        
        if !tags.isEmpty {
            scenario["tags"] = tags.export()
        }
        
        if let description = description, !description.isEmpty {
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
