import Foundation

protocol KeywordLocalizable {
    
}

extension GherkinKeyword where Self: KeywordLocalizable & RawRepresentable, Self.RawValue == String {
    
    func keywords(language: FeatureLanguage) -> [String] {
        let translations = LanguageDictionary(language: language.identifier).translations(keyword: self.rawValue)
        
        return translations.map { $0 + suffix.stringValue }
    }
    
}
