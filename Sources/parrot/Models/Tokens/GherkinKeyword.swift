import Foundation

protocol GherkinKeyword {
    var keyword: String? { get }
}

extension GherkinKeyword {
    
    var keyword: String? {
        return nil
    }
    
}

extension GherkinKeyword where Self: RawRepresentable, Self.RawValue == String {
    
    var keyword: String? {
        return rawValue
    }
    
}

enum StepKeyword: String, CaseIterable, GherkinKeyword {
    case given = "Given"
    case when = "When"
    case then = "Then"
    case and = "And"
    case but = "But"
}

enum PrimaryKeyword: String, CaseIterable, GherkinKeyword {
    case feature = "Feature"
    case rule = "Rule"
    
    case background = "Background"
    
    case scenario = "Scenario"
    case example = "Example"
    case scenarioOutline = "Scenario Outline"
    case scenarioTemplate = "Scenario Template"
    
    case examples = "Examples"
    
    var keyword: String {
        return rawValue //TODO: multiple languages
    }
}

enum SecondaryKeyword: GherkinKeyword {   
    case comment
    case docStrings(mark: String?)
    case pipe
    case tag(value: String)
}

struct Expression: GherkinKeyword {
    let content: String
}

struct EOF: GherkinKeyword {}
struct DocString: GherkinKeyword {}
