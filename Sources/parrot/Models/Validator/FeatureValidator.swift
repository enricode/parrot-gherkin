import Foundation

struct FeatureValidator: Validator {
    
    let mode: CucumberInterpreter.Mode
    
    func validate(object: Feature) throws -> Bool {
        guard mode != .permissive else {
            return true
        }
        
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
