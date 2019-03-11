import Foundation

enum GherkinKeywordSuffix {
    case none
    case partOfKeyword
    case discardable(String)
}

protocol GherkinKeyword {
    var keywordIdentifier: String? { get }
    var suffix: GherkinKeywordSuffix { get }
}

extension GherkinKeyword {
    
    var keywordIdentifier: String? {
        return nil
    }
    
    var suffix: GherkinKeywordSuffix {
        return .none
    }
    
}

extension GherkinKeyword where Self: RawRepresentable, Self.RawValue == String {
    
    var keywordIdentifier: String? {
        return rawValue
    }
    
}

protocol Findable {
    
    static var keywords: [String] { get }
    init?(keyword: String)
    
}

extension Findable where Self: RawRepresentable & CaseIterable, Self.RawValue == String {
    
    init?(keyword: String) {
        self.init(rawValue: keyword)
    }
    
}

extension Findable where Self: GherkinKeyword & RawRepresentable & CaseIterable, Self.RawValue == String {
    
    static var keywords: [String] {
        return Self.allCases.compactMap { $0.keywordIdentifier }
    }
    
}

enum StepKeyword: String, CaseIterable, GherkinKeyword, Findable {
    case given = "Given"
    case when = "When"
    case then = "Then"
    case and = "And"
    case but = "But"
}

enum PrimaryKeyword: String, CaseIterable, GherkinKeyword, Findable {
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
    
    var suffix: GherkinKeywordSuffix {
        return .discardable(":")
    }
}

struct SecondaryKeyword: GherkinKeyword, Findable {
    static var keywords: [String] = KeyType.allCases.map { $0.rawValue }
    
    enum KeyType: String, CaseIterable {
        case comment = "#"
        case docStrings = "\"\"\""
        case pipe = "|"
        case tag = "@"
    }
    
    enum KeyContent {
        case some(String)
        case none
    }
    
    let type: KeyType
    let content: KeyContent
    
    init(type: KeyType, content: KeyContent = .none) {
        self.type = type
        self.content = content
    }
    
    init?(keyword: String) {
        switch keyword {
        case KeyType.comment.rawValue:
            type = .comment
            content = .none
        case KeyType.pipe.rawValue:
            type = .pipe
            content = .none
        default:
            let trimmed = keyword.trimmingCharacters(in: .whitespaces)
            
            if keyword.starts(with: KeyType.docStrings.rawValue) {
                if let afterDocStringsIndex = trimmed.range(of: KeyType.docStrings.rawValue)?.upperBound {
                    type = .docStrings
                    
                    if afterDocStringsIndex == trimmed.endIndex {
                        content = .none
                    } else {
                        content = KeyContent.some(String(trimmed.suffix(from: afterDocStringsIndex)))
                    }
                } else {
                    return nil
                }
            } else if keyword.starts(with: KeyType.tag.rawValue) {
                guard trimmed.count > 1 else {
                    return nil
                }

                type = .tag
                content = KeyContent.some(String(trimmed.suffix(from: trimmed.index(after: keyword.startIndex))))
            } else {
                return nil
            }
        }
    }
    
    var suffix: GherkinKeywordSuffix {
        switch type {
        case .comment, .pipe: return .none
        case .docStrings, .tag: return GherkinKeywordSuffix.partOfKeyword
        }
    }
}

/*
enum SecondaryKeyword: GherkinKeyword, Findable {
    case comment
    case docStrings(mark: String?)
    case pipe
    case tag(value: String)
    
    struct Keywords {
        static let comment = "#"
        static let docStrings = "\"\"\""
        static let pipe = "|"
        static let tag = "@"
    }
    
    static var keywords: [String] {
        return [
            Keywords.docStrings,
            Keywords.comment,
            Keywords.pipe,
            Keywords.tag
        ]
    }
    
    init?(keyword: String) {
        switch keyword {
        case Keywords.comment: self = .comment
        case Keywords.pipe: self = .pipe
        default:
            if keyword.starts(with: Keywords.docStrings), let afterDocStringsIndex = keyword.range(of: Keywords.docStrings)?.upperBound {
                let endMarkIndex = keyword.suffix(from: afterDocStringsIndex).firstIndex(of: " ") ?? keyword.endIndex
                if endMarkIndex == afterDocStringsIndex {
                    self = .docStrings(mark: nil)
                } else {
                    self = .docStrings(mark: String(keyword.suffix(from: afterDocStringsIndex)).trimmingCharacters(in: .whitespaces))
                }
            } else if keyword.starts(with: Keywords.comment) {
                let tagName = String(keyword.dropFirst().split(separator: " ").first ?? "")
                if tagName.isEmpty {
                    return nil
                } else {
                    self = .tag(value: tagName)
                }
            }
            
            return nil
        }
    }
    
    var representation: String {
        switch self {
        case .comment: return Keywords.comment
        case .docStrings(let mark): return Keywords.docStrings + (mark ?? "")
        case .pipe: return Keywords.pipe
        case .tag(let value): return Keywords.tag + value
        }
    }
    
    var keyword: String? {
        switch self {
        case .docStrings(_):
            return Keywords.docStrings
        case .comment:
            return Keywords.comment
        case .pipe:
            return Keywords.pipe
        case .tag(_):
            return Keywords.tag
        }
    }
    
    var suffix: GherkinKeywordSuffix {
        switch self {
        case .comment: return .none
        case .docStrings(_): return .
        }
    }
}
*/

struct Expression: GherkinKeyword {
    let content: String
}

struct EOF: GherkinKeyword {}
struct DocString: GherkinKeyword {}
