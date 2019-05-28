import Foundation

public struct Tag: AST, Equatable {
    let tag: String
    
    public func export() -> [String : Any] {
        return ["name": tag]
    }
}
