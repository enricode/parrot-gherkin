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

struct DocString: GherkinKeyword, Equatable {
    static var keyCount: Int { return keyword.count }
    static let keyword = "\"\"\""
    
    let mark: String?
    
    var lenght: UInt {
        return UInt(DocString.keyCount + (mark ?? "").count)
    }
}

struct Comment: GherkinKeyword, Equatable {
    static var keyCount: Int { return keyword.count }
    static let keyword = "#"
    
    let originalContent: String
    let trimmedContent: String
    
    init(content: String) {
        originalContent = content
        trimmedContent = content.trimmingCharacters(in: .whitespaces)
    }
    
    var lenght: UInt {
        return UInt(Comment.keyCount + originalContent.count)
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
}

struct NextContentMatcher: KeywordMatcher {
    
    func matches(sentence: String) -> GherkinKeyword? {
        if sentence.starts(with: DocString.keyword) {
            if sentence.count == DocString.keyCount {
                return DocString(mark: nil)
            } else if let mark = sentence.suffix(from: sentence.index(sentence.startIndex, offsetBy: 3)).split(separator: " ").first {
                return DocString(mark: String(mark))
            } else {
                return DocString(mark: nil)
            }
        } else if sentence.starts(with: "#") {
            return Comment(content: String(sentence.suffix(from: sentence.index(after: sentence.startIndex))))
        }
        return nil
    }

}
