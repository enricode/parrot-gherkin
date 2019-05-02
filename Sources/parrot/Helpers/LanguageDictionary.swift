import Foundation

enum LanguageDictionaryInitException: Error {
    case invalidLanguage(String)
}

struct LanguageDictionary {
    let language: String
    let dictionary: [String: Any]
    
    init(language: String) throws {
        self.language = language
        
        let bundle = Bundle(for: CucumberLexer.self)
        
        guard let gherkinLanguageFileURL = bundle.url(forResource: "gherkin-languages", withExtension: "json") else {
            print("Cannot load gherkin languages file")
            dictionary = [:]
            return
        }
        
        guard let languagesJSON = (try? JSONSerialization.jsonObject(with: Data(contentsOf: gherkinLanguageFileURL), options: [])) as? [String: Any] else {
            print("Cannot parse gherkin languages file")
            dictionary = [:]
            return
        }
        
        guard let dictionary = languagesJSON[language] as? [String: Any] else {
            throw LanguageDictionaryInitException.invalidLanguage(language)
        }
        
        self.dictionary = dictionary
    }
    
    func translations(keyword: String) -> [String] {
        return dictionary[keyword] as? [String] ?? dictionary["en"] as? [String] ?? []
    }
    
}
