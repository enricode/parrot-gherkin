import Foundation

enum FeatureInitializationException: String, ParrotError {
    case emptyTitle
    case emptyScenarios
    case emptyDescription
}

public struct Feature: AST, Equatable {
    let language: String
    let tags: [ASTNode<Tag>]
    let keyword: String
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    let rules: [ASTNode<Rule>]
}

extension Feature {
    
    public func export() -> [String : Any] {
        var feature: [String : Any] = [
            "children": scenarios.export(),
            "keyword": keyword,
            "language": language
        ]
        
        if let title = title {
            feature["name"] = title
        }
        
        if let description = description {
            feature["description"] = description
        }
        
        if !tags.isEmpty {
            feature["tags"] = tags.export()
        }
        
        return feature
    }
    
}
