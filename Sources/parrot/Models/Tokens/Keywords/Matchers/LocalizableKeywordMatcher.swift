import Foundation

struct LocalizableKeywordMatcher<T: GherkinKeyword & CaseIterable>: KeywordMatcher {
    
    func matches(sentence: String, language: FeatureLanguage) throws -> KeywordMatch? {
        let keywords: [(keyword: T, matches: [String])] = try T.allCases.map { ($0, try $0.keywords(language: language)) }
        
        let matchedKeyword = keywords.reduce(Optional<(k: GherkinKeyword, v: String)>.none, { result, keyword in
            guard result == nil else {
                return result
            }
            
            let foundKeywords = keyword.matches.compactMap { stringKey in
                sentence.starts(with: stringKey) ? stringKey : nil
            }
            
            if let foundKeyword = foundKeywords.first {
                return (k: keyword.keyword, v: foundKeyword)
            }
            
            return nil
        })
        
        guard let matched = matchedKeyword else {
            return nil
        }
        
        return KeywordMatch(keyword: matched.k, value: matched.v)
    }

}
