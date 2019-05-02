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
    
    // \| \\ \n
    var removingEscape: String {
        var currentIndex = startIndex
        var result = ""

        while currentIndex != endIndex {
            let nextIndex = index(after: currentIndex)
            
            guard nextIndex != endIndex else {
                return result.appending(String(self[currentIndex]))
            }
            
            switch (self[currentIndex], self[nextIndex]) {
            case ("\\", "\\"), ("\\", "|"):
                result.append(self[nextIndex])
                currentIndex = index(after: nextIndex)
            case ("\\", "n"):
                result.append("\n")
                currentIndex = index(after: nextIndex)
            default:
                result.append(self[currentIndex])
                currentIndex = nextIndex
            }
        }
        
        return result
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
