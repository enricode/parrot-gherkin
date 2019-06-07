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
        let children: [[String: Any]] = scenarios.map { scenario in
            let info = scenario.export()
            return [scenario.element.keyword.type.rawValue: info]
        }
        
        var feature: [String : Any] = [
            "keyword": keyword,
            "language": language
        ]
        
        if !children.isEmpty {
            feature["children"] = children
        }
        
        if let title = title, !title.isEmpty {
            feature["name"] = title
        }
        
        if let description = description, !description.isEmpty {
            feature["description"] = description
        }
        
        if !tags.isEmpty {
            feature["tags"] = tags.export()
        }
        
        return feature
    }
    
}
