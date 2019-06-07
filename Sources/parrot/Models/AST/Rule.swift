import Foundation

public struct Rule: AST, Equatable {
    let title: String?
    let description: String?
    let scenarios: [ASTNode<Scenario>]
    
    public func export() -> [String : Any] {
        var rule: [String: Any] = [
            "children": scenarios.export()
        ]
        
        if let title = title, !title.isEmpty {
            rule["title"] = title
        }
        
        if let description = description, !description.isEmpty {
            rule["description"] = description
        }
        
        return rule
    }
}
