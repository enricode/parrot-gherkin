import Foundation

protocol KeywordMatcher {
    func matches(sentence: String) -> GherkinKeyword?
}

protocol KeywordLocalizable {
    func keyword(language: GherkinLanguage) -> String
}

enum GherkinLanguage {
    case english
}

protocol GherkinKeyword: TokenType {
    var lenght: UInt { get }
}

enum PrimaryKeyword: String, CaseIterable, GherkinKeyword, KeywordLocalizable, Equatable {
    case feature = "Feature"
    case rule = "Rule"
    
    case background = "Background"
    
    case scenario = "Scenario"
    case example = "Example"
    case scenarioOutline = "Scenario Outline"
    case scenarioTemplate = "Scenario Template"
    
    case examples = "Examples"
    
    func keyword(language: GherkinLanguage = .english) -> String {
        return rawValue + ":"
    }
    
    var lenght: UInt {
        return UInt(keyword().count)
    }
}

enum StepKeyword: String, CaseIterable, GherkinKeyword, KeywordLocalizable, Equatable {
    case given = "Given"
    case when = "When"
    case then = "Then"
    case and = "And"
    case but = "But"
    
    func keyword(language: GherkinLanguage = .english) -> String {
        return rawValue
    }
    
    var lenght: UInt {
        return UInt(keyword().count)
    }
}

struct LocalizableKeywordMatcher<T: GherkinKeyword & CaseIterable & KeywordLocalizable>: KeywordMatcher {
    let keywords: [(keyword: T, match: String)] = T.allCases.map { ($0, $0.keyword(language: .english)) }
    
    func matches(sentence: String) -> GherkinKeyword? {
        guard let matched = keywords.first(where: { sentence.starts(with: $0.match) }) else {
            return nil
        }
        
        return matched.keyword
    }
}

struct EOF: TokenType, Equatable {}

struct DocStringKeyword: GherkinKeyword, Equatable {
    static var keyCount: Int { return 3 }
    
    enum Keyword: String {
        case doubleQuotes = "\"\"\""
        case backticks = "```"
        
        init?(parsing: String) {
            if parsing.starts(with: Keyword.doubleQuotes.rawValue) {
                self = .doubleQuotes
                return
            }
            
            if parsing.starts(with: Keyword.backticks.rawValue) {
                self = .backticks
                return
            }
            
            return nil
        }
    }
    
    let mark: String?
    let keyword: Keyword
    
    var lenght: UInt {
        return UInt(DocStringKeyword.keyCount + (mark ?? "").count)
    }
}

struct CommentKeyword: GherkinKeyword, Equatable {
    static var keyCount: Int { return keyword.count }
    static let keyword = "#"
    
    let originalContent: String
    let trimmedContent: String
    
    init(content: String) {
        originalContent = content
        trimmedContent = content.trimmingCharacters(in: .whitespaces)
    }
    
    var lenght: UInt {
        return UInt(CommentKeyword.keyCount + originalContent.count)
    }
}

struct Expression: GherkinKeyword, Equatable {
    let content: String

    var lenght: UInt {
        return UInt(content.count)
    }
}

enum SecondaryKeyword: GherkinKeyword, Equatable {
    case pipe
    case tag(name: String)
    
    var lenght: UInt {
        switch self {
        case .pipe: return 1
        case .tag(let name): return UInt(name.count + 1)
        }
    }
    
    func isSameType(as object: Any) -> Bool {
        guard let other = object as? SecondaryKeyword else {
            return false
        }
        
        switch (other, self) {
        case (.pipe, .pipe), (.tag, .tag): return true
        default: return false
        }
    }
}

struct NextContentMatcher: KeywordMatcher {
    
    func matches(sentence: String) -> GherkinKeyword? {
        if let docStringsKeyword = DocStringKeyword.Keyword(parsing: sentence) {
            if sentence.count == DocStringKeyword.keyCount {
                return DocStringKeyword(mark: nil, keyword: docStringsKeyword)
            } else if let mark = sentence.suffix(from: sentence.index(sentence.startIndex, offsetBy: DocStringKeyword.keyCount)).split(separator: " ").first {
                return DocStringKeyword(mark: String(mark), keyword: docStringsKeyword)
            } else {
                return DocStringKeyword(mark: nil, keyword: docStringsKeyword)
            }
        } else if sentence.starts(with: "#") {
            return CommentKeyword(content: String(sentence.suffix(from: sentence.index(after: sentence.startIndex))))
        }
        return nil
    }

}

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
