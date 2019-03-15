import Foundation

extension String {
    
    var endsWithColon: Bool {
        return last == ":"
    }
    
    var isDocString: Bool {
        return self == "\"\"\""
    }
}

extension NSString {
    
    private static var invalidCharacters: CharacterSet = {
        var invalidCharacters = CharacterSet()
        
        let invalidCharacterSets: [CharacterSet] = [
            .whitespacesAndNewlines,
            .illegalCharacters,
            .controlCharacters,
            .punctuationCharacters,
            .nonBaseCharacters,
            .symbols
        ]
        
        for invalidSet in invalidCharacterSets {
            invalidCharacters.formUnion(invalidSet)
        }
        
        return invalidCharacters
    }()
    
    @objc var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: NSString.invalidCharacters)
        let result = validComponents.joined(separator: "_")
        
        return result.isEmpty ? "_" : result
    }

}
