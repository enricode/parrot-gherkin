import Foundation

enum GherkinKeywordSuffix {
    case none
    case partOfKeyword(String)
    case discardable(String)
}

protocol GherkinKeyword {
    var keyword: String? { get }
    var suffix: GherkinKeywordSuffix { get }
}

extension GherkinKeyword {
    
    var keyword: String? {
        return nil
    }
    
    var suffix: GherkinKeywordSuffix {
        return .none
    }
    
}

extension GherkinKeyword where Self: RawRepresentable, Self.RawValue == String {
    
    var keyword: String? {
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
        return Self.allCases.compactMap { $0.keyword }
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

struct Expression: GherkinKeyword {
    let content: String
}

struct EOF: GherkinKeyword {}
struct DocString: GherkinKeyword {}
