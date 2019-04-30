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
        
        /*var result = ""
        var iterator = makeIterator()
        
        var previous = iterator.next()
        
        while var current = iterator.next() {
            if previous == "\\" && current != "\\" {
                result.append(previous!)
                result.append(current)
            } else if
            
            current = next
        }*/
        
        
        
        
        /*
        reduce(("", SlashDetection.begin)) { result, nextElement in
            switch (result.1, nextElement) {
            case (.begin, _):
                return ("", SlashDetection(character: nextElement)
            }
        }
        */
        
        /*var result = ""
        
        var iterator = makeIterator()
        var lastCharacter = iterator.next()
        
        (0...count-1).forEach { index in
            let actual = self[String.Index.init(utf16Offset: index, in: self)]
            let next = self[String.Index.init(utf16Offset: index + 1, in: self)]
            
            switch (actual, next) {
            case ("\\", _) where next != "\\":
                result.append(contentsOf: next)
            case ("\\", "\\"), ("\\", "|"):
                
            default:
                
            }
        }
        */
        /*
        guard lastCharacter != nil else {
            return ""
        }
        
        while let currentCharacter = iterator.next() {
            switch (lastCharacter, currentCharacter) {
            case (.none, "\\"):
                return ""
            case (.none, ):
                
            
            
            case (.none, _) where character != "\\":
                result.append(character)
            case (.some, "\\"):
                
            case (.some(let lastChar), "|") where lastChar == "\\",
                 (.some(let lastChar), "\\") where lastChar == "\\":
                result.append(character)
            case (.some(let lastChar), _) where lastChar == "\\":
                result.append(lastChar)
                result.append(character)
            default:
                result.append(character)
            }
            
            lastCharacter = character
        }
         */
        
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
