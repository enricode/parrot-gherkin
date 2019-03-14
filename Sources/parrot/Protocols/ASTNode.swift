import Foundation

struct ASTNode<T: AST & Equatable>: Equatable {
    let element: T
    let location: Location
    
    init(_ element: T, location: Location) {
        self.element = element
        self.location = location
    }
}
