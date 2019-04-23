import Foundation

enum LexerExceptions: ParrotError {
    case cannotPeekUntilNotExistentChar(char: Character)
    case cannotAdvanceUntilNotExistentChar(char: Character)
    case unexpectedEOFWhileParsingDocString(docString: String)
}

class CucumberLexer: Lexer {
    
    enum LexerContext {
        case normal
        case table
        case docstring(offset: DocStringOffset, startedWith: DocStringKeyword.Keyword)
        
        var isTable: Bool {
            if case .table = self { return true }
            return false
        }
        
        var isDocstring: Bool {
            if case .docstring(_, _) = self { return true }
            return false
        }
    }
    
    enum DocStringOffset {
        case none
        case offset(Int)
        
        var intValue: Int {
            switch self {
            case .none: return 0
            case .offset(let value): return value
            }
        }
    }
    
    private var docStringsLeadingOffset: DocStringOffset = .none
    
    let text: String
    private(set) var position: String.Index
    
    private var currentChar: LexerCharacter = .none
    private var currentContext: LexerContext = .normal
    private var currentLocation: Location = .start
    private var currentLanguage: FeatureLanguage?
    
    init(feature: String) {
        text = feature
        position = text.startIndex

        updateCurrentChar()
        advanceCurrentLocation()
    }
    
    private var hasStillCharAhead: Bool {
        return position != text.endIndex
    }
    
    private func updateCurrentChar() {
        if position == text.endIndex {
            currentChar = .none
            currentContext = .normal
        } else {
            currentChar = LexerCharacter(char: text[position])
        }
    }
    
    private func advanceCurrentLocation() {
        if currentChar == .newLine {
            currentLocation = Location(column: 0, line: currentLocation.line + 1)
            
            if currentContext.isTable {
                currentContext = .normal
            }
        } else {
            currentLocation = currentLocation.advance()
        }
    }
    
    private func advance() {
        position = text.index(after: position)

        updateCurrentChar()
        advanceCurrentLocation()
    }
    
    private func advance(positions: UInt) {
        guard positions > 0 else {
            return
        }
        
        (1...positions).forEach { _ in advance() }
    }
    
    private func peek(until condition: (LexerCharacter) -> Bool) -> String? {
        var offset: String.IndexDistance = 0
        var conditionResult: Bool = true
        
        repeat {
            let offsettedPosition = text.index(position, offsetBy: offset)
            
            guard offsettedPosition != text.endIndex else {
                break
            }
            
            let character = LexerCharacter(char: text[offsettedPosition])
            conditionResult = condition(character)
            
            if conditionResult {
                offset += 1
            }
        } while conditionResult
        
        return String(text.suffix(from: position).prefix(upTo: text.index(position, offsetBy: offset)))
    }
    
    private func skip(characterSet: Set<LexerCharacter>) {
        while currentChar != .none, characterSet.contains(currentChar) {
            advance()
        }
    }
    
    private func characterLimitNotFound(_ limitAt: LexerCharacter?) -> Bool {
        guard let characterLimit = limitAt else { return true }
    
        return characterLimit.representation != currentChar.representation
    }
    
    private func extractAllAvoiding(chars: [LexerCharacter], limitAt: LexerCharacter? = nil) -> String {
        var result = ""
        
        while currentChar.isNotOne(of: chars) && characterLimitNotFound(limitAt) {
            result.append(currentChar.representation)
            advance()
        }
        
        return result
    }
    
    private func sentence(limitAt limit: LexerCharacter? = nil) -> String {
        return  extractAllAvoiding(chars: [.none, .newLine], limitAt: limit)
    }
    
    private func word(limitAt limit: LexerCharacter? = nil) -> String {
        return extractAllAvoiding(chars: [.none, .whitespace, .newLine], limitAt: limit)
    }
    
    private func genericParse() -> Token {
        switch currentContext {
        case .normal, .docstring(_):
            return genericKeywordParse()
        case .table:
            return genericDataTableParse()
        }
    }
    
    private func genericKeywordParse() -> Token {
        let location = currentLocation
        
        guard let line = peek(until: { $0.isNotOne(of: [.newLine, .none]) }) else {
            return Token(.eof, currentLocation)
        }
        
        let finder = KeywordFinder(line: line, language: currentLanguage)
        
        guard let match = finder.findKeyword() else {
            return Token(.expression, value: sentence().trimmed, location)
        }
        
        advance(positions: UInt(match.value.count))
        
        if let docStringKeyword = match.keyword as? DocStringKeyword {
            if currentContext.isDocstring {
                currentContext = .normal
            } else {
                currentContext = .docstring(offset: .none, startedWith: docStringKeyword.keyword)
            }
        }
        
        return Token(.keyword(match.keyword), value: match.value, location)
    }
    
    private func genericDataTableParse() -> Token {
        let location = currentLocation
        
        guard currentChar != .pipe else {
            advance()
            return Token(.keyword(SecondaryKeyword.pipe), value: "|", location)
        }
        
        guard let line = peek(until: { $0.isNotOne(of: [.newLine, .none, .pipe]) })?.trimmingCharacters(in: .whitespaces) else {
            return Token(.eof, currentLocation)
        }
        
        advance(positions: UInt(line.count))
        
        return Token(.expression, value: line.trimmed, location)
    }
    
    func getNextToken() throws -> Token {
        while currentChar != .none {
            var location = currentLocation
            
            if currentChar == .whitespace {
                skip(characterSet: [.whitespace])
                continue
            }
            
            if case .docstring(let offset, let start) = currentContext, !currentChar.isQuotes {
                if currentChar == .newLine {
                    advance()
                    skip(characterSet: [.whitespace])
                    if location.line < currentLocation.line {
                        return Token(.expression, location.resettingColumn)
                    }
                    location = currentLocation
                }
                if currentChar.isQuotes {
                    if peek(until: { $0.isQuotes }) == start.rawValue {
                        currentContext = .normal
                        return Token(.keyword(DocStringKeyword(mark: nil, keyword: start)), value: sentence(), location)
                    }
                } else if currentChar == .none {
                    return Token(.eof, currentLocation)
                }
                
                let value = sentence().replacingOccurrences(of: "\\\"", with: "\"")
                
                switch offset {
                case .none:
                    currentContext = .docstring(offset: .offset(location.column), startedWith: start)
                    return Token(.expression, value: value, location.resettingColumn)
                case .offset(let offset):
                    let value = value.padded(leading: max(location.column - offset, 0))
                    return Token(.expression, value: value, location.resettingColumn)
                }
            }
            
            switch currentChar {
            case .newLine:
                skip(characterSet: [.newLine])
                continue
            case .comment:
                advance()
                let comment = sentence()
                let trimmed = comment.trimmed
                
                if let range = trimmed.range(of: #"\s*language\s*:\s*\S*\s*$"#, options: .regularExpression),
                    range.lowerBound == trimmed.startIndex, range.upperBound == trimmed.endIndex,
                    let language = trimmed.components(separatedBy: ":").last?.trimmed
                {
                    currentLanguage = FeatureLanguage(identifier: language)
                    return Token(.language(language), value: "#" + comment, location)
                } else {
                    return Token(.comment(comment.trimmingCharacters(in: .whitespacesAndNewlines)), value: "#" + comment, location)
                }
            case .tag:
                if hasStillCharAhead {
                    advance()
                    let tag = word()
                    return Token(.keyword(SecondaryKeyword.tag(name: tag)), value: "@\(tag)", location)
                } else {
                    return Token(.expression, value: String(LexerCharacter.tag.representation), location)
                }
            case .pipe:
                advance()
                
                if currentChar != .newLine {
                    currentContext = .table
                }
                
                return Token(.keyword(SecondaryKeyword.pipe), value: "|", location)
            case .generic(_), .colon, .quotes:
                return genericParse()
            case .tab:
                advance()
            case .none, .whitespace:
                fatalError("This should never happen")
            }
        }
        
        return Token(.eof, currentLocation)
    }
    
    func parse() throws -> [Token] {
        let lastPosition = position
        
        position = text.startIndex
        
        var tokens: [Token] = []
        
        while true {
            let nextToken = try getNextToken()
            tokens.append(nextToken)

            if nextToken == .eof {
                break
            }
        }
        
        position = lastPosition
        
        return tokens
    }
    
}
