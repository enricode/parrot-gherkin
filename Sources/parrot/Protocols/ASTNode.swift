import Foundation

public struct ASTNode<ASTElement: AST & Equatable>: Equatable {
    let element: ASTElement
    let location: Location
    
    init(_ element: ASTElement, location: Location) {
        self.element = element
        self.location = location
    }
    
}

extension ASTNode: Exportable {
    
    public func export() -> [String: Any] {
        var data = element.export()
        data["location"] = location.export()
        
        return data
    }
    
}
