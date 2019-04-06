import Foundation

struct KeywordFinder {
    let line: String
    let language: FeatureLanguage
    let matchers: [KeywordMatcher]
    
    struct NotFound: Error {}
    
    init(line: String, language: FeatureLanguage?, matchers: [KeywordMatcher] = Config.matchers) {
        self.line = line
        self.matchers = matchers
        self.language = language ?? FeatureLanguage(identifier: "en")
    }
    
    func findKeyword() -> KeywordMatch? {
        return matchers.reduce(Optional<KeywordMatch>.none) { currentResult, matcher in
            guard currentResult == nil else {
                return currentResult
            }
            
            if let match = matcher.matches(sentence: line, language: language) {
                return match
            } else {
                return nil
            }
        }
    }
}
