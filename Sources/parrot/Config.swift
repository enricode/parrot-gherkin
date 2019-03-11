import Foundation

struct Config {
    static let matchers: [KeywordMatcher] = [
        LocalizableKeywordMatcher<PrimaryKeyword>(),
        LocalizableKeywordMatcher<StepKeyword>(),
        NextContentMatcher()
    ]
}
