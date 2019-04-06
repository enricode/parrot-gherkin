import Foundation

enum PrimaryKeyword: String, GherkinKeyword, CaseIterable, Equatable, KeywordLocalizable {
    case feature
    case rule
    case background
    case scenario
    case scenarioOutline
    case examples
    
    var suffix: GherkinSuffix {
        return .suffix(":")
    }
}
