import Foundation

enum GherkinSuffix {
    case noSuffix
    case suffix(String)
    
    var stringValue: String {
        guard case .suffix(let string) = self else {
            return ""
        }
        return string
    }
}

protocol GherkinKeyword {
    var suffix: GherkinSuffix { get }
    func keywords(language: FeatureLanguage) throws -> [String]
}

extension GherkinKeyword {
    var suffix: GherkinSuffix {
        return .noSuffix
    }
    
    func keywords(language: FeatureLanguage) throws -> [String] {
        return []
    }
}

struct Expression: GherkinKeyword, Equatable {
    let content: String

    var lenght: UInt {
        return UInt(content.count)
    }

}

/*
extension Token {
    
    var isScenarioKeyword: Bool {
        guard let primaryKey = self.type as? PrimaryKeyword else {
            return false
        }
        
        switch primaryKey {
        case .scenario, .scenarioOutline, .scenarioTemplate, .example, .background:
            return true
        default:
            return false
        }
    }
    
    var isRuleKeyword: Bool {
        guard let primaryKey = self.type as? PrimaryKeyword else {
            return false
        }
        return primaryKey == .rule
    }
    
    var isScenarioOutlineKey: Bool {
        guard let primaryKey = self.type as? PrimaryKeyword else {
            return false
        }
        return primaryKey == .scenarioOutline || primaryKey == .scenarioTemplate
    }
    
    var isExamplesToken: Bool {
        guard let primaryKey = self.type as? PrimaryKeyword else {
            return false
        }
        return primaryKey == .examples
    }
    
    var isExpressionOrPipe: Bool {
        return self.type.isSameType(as: SecondaryKeyword.pipe) || self.type is Expression
    }
    
    var isTagToken: Bool {
        guard let secondaryKeyword = self.type as? SecondaryKeyword else {
            return false
        }
        
        switch secondaryKeyword {
        case .tag:
            return true
        default:
            return false
        }
    }
    
    var isStepKeyword: Bool {
        return self.type is StepKeyword
    }
    
    func isDocStringOf(type: DocStringKeyword.Keyword) -> Bool {
        guard let docString = self.type as? DocStringKeyword else {
            return false
        }
        
        return docString.keyword == type
    }
    
}
*/
