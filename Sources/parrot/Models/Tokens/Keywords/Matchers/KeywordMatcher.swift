import Foundation

struct KeywordMatch {
    let keyword: GherkinKeyword
    let value: String
}

protocol KeywordMatcher {
    func matches(sentence: String, language: FeatureLanguage) -> KeywordMatch?
}
