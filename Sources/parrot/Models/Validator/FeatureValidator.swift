import Foundation

struct FeatureValidator: Validator {
    
    func validate(object: Feature) throws -> Bool {        
        if let title = object.title, title.isEmpty {
            throw FeatureInitializationException.emptyTitle
        }
        
        if let desc = object.description, desc.isEmpty {
            throw FeatureInitializationException.emptyDescription
        }
        
        if object.scenarios.isEmpty {
            throw FeatureInitializationException.emptyScenarios
        }
        
        return true
    }
    
}
