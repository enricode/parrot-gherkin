import Foundation

extension String {
    
    var endsWithColon: Bool {
        return last == ":"
    }
    
    var isDocString: Bool {
        return self == "\"\"\""
    }
    
    var removingColon: String {
        return replacingOccurrences(of: ":", with: "")
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func padded(leading: Int) -> String {
        return String(repeatElement(" ", count: leading)) + self
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
    
    @objc public var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: NSString.invalidCharacters)
        let result = validComponents.joined(separator: "_")
        
        return result.isEmpty ? "_" : result
    }

}
