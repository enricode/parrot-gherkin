import Foundation

struct NextContentMatcher: KeywordMatcher {
    
    func matches(sentence: String, language: FeatureLanguage) throws -> KeywordMatch? {
        if let docStringKeyword = DocStringKeyword.Keyword(parsing: sentence) {
            let keyword = extractDocStringKeyword(from: sentence, keyword: docStringKeyword)
            return KeywordMatch(keyword: keyword, value: docStringKeyword.rawValue + (keyword.mark ?? ""))
        }
        return nil
    }
    
    private func extractDocStringKeyword(from sentence: String, keyword: DocStringKeyword.Keyword) -> DocStringKeyword {
        if sentence.count == DocStringKeyword.keyCount {
            return DocStringKeyword(mark: nil, keyword: keyword)
        } else if let mark = sentence.suffix(from: sentence.index(sentence.startIndex, offsetBy: DocStringKeyword.keyCount)).split(separator: " ").first {
            return DocStringKeyword(mark: String(mark), keyword: keyword)
        } else {
            return DocStringKeyword(mark: nil, keyword: keyword)
        }
    }
    
}
