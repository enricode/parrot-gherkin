import Foundation

struct KeywordFinder {
    let line: String
    let matchers: [KeywordMatcher]
    
    init(line: String, matchers: [KeywordMatcher] = Config.matchers) {
        self.line = line
        self.matchers = matchers
    }
    
    func findKeyword() -> GherkinKeyword? {
        guard let matcher = matchers.first(where: { $0.matches(sentence: line) != nil }) else {
            return nil
        }
        
        return matcher.matches(sentence: line)
    }
}
