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
    let title: String
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    let language: FeatureLanguage = .english
    
    init(tags: [ASTNode<Tag>], title: String, description: String?, scenarios: [ASTNode<Scenario>]) throws {
        self.tags = tags
        
        self.title = title
        if title.isEmpty {
            throw FeatureInitializationException.emptyTitle
        }
        
        self.description = description
        if let desc = description, desc.isEmpty {
            throw FeatureInitializationException.emptyDescription
        }
        
        self.scenarios = scenarios
        if scenarios.isEmpty {
            throw FeatureInitializationException.emptyScenarios
        }
    }
}
