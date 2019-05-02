import Foundation

protocol KeywordLocalizable {
    
}

extension GherkinKeyword where Self: KeywordLocalizable & RawRepresentable, Self.RawValue == String {
    
    func keywords(language: FeatureLanguage) throws -> [String] {
        let translations = try LanguageDictionary(language: language.identifier).translations(keyword: self.rawValue)
        
        return translations.map { $0 + suffix.stringValue }
    }
    
}
