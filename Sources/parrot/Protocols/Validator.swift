import Foundation

protocol Validator {
    associatedtype Object
    
    func validate(object: Object) throws -> Bool
}
