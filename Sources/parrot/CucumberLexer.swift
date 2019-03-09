//
//  Lexer.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

enum LexerExceptions: ParrotError {
    case cannotPeekUntilNotExistentChar(char: Character)
    case cannotAdvanceUntilNotExistentChar(char: Character)
    case unexpectedEOFWhileParsingDocString(docString: String)
}

class CucumberLexer: Lexer {
    
    enum LexerContext {
        case none
        case table
        case docString
    }
    
    let text: String
    private(set) var position: String.Index
    
    private var currentChar: LexerCharacter = .none
    private var currentContext: LexerContext = .none
    private var currentLocation: Location = .start
    
    init(feature: String) {
        text = feature
        position = text.startIndex

        advance(positions: 0)
    }
    
    private var hasStillCharAhead: Bool {
        return position != text.endIndex
    }
    
    private func advance(positions: UInt = 1) {
        position = text.index(position, offsetBy: Int(positions))

        if position == text.endIndex {
            currentChar = .none
        } else {
            currentChar = LexerCharacter(char: text[position])
        }
        
        if currentChar == .newLine {
            currentLocation = Location(column: 0, line: currentLocation.line + 1)
        } else {
            currentLocation = currentLocation.advancedBy(column: positions)
        }
    }
    
    private func advance(until char: Character, orEOF stopAtEOF: Bool = false) throws {
        let stopAt = LexerCharacter(char: char)
        
        while currentChar != stopAt, currentChar != .none {
            advance()
        }
        
        if position == text.endIndex, currentChar != stopAt, !stopAtEOF {
            throw LexerExceptions.cannotAdvanceUntilNotExistentChar(char: char)
        }
    }
    
    private func peek(count: Int) -> [Character] {
        assert(count > 0, "Count should be > 0")
        let offsets: [Int] = Array(0...(count-1))
        
        let chars = offsets.compactMap { offset -> Character? in
            guard let nextIndex = text.index(position, offsetBy: offset + 1, limitedBy: text.endIndex) else {
                return nil
            }
            guard nextIndex != text.endIndex else {
                return nil
            }
            return text[nextIndex]
        }
        
        return chars
    }
    
    private func peek(count: Int) -> String? {
        return String(peek(count: count) as [Character])
    }
    
    private func peek(until characterDelimiter: Character) -> String? {
        guard let characterIndex = text.suffix(from: position).firstIndex(of: characterDelimiter) else {
            return nil
        }
        return String(text.suffix(from: position).prefix(upTo: characterIndex))
    }
    
    private func peek(until condition: (LexerCharacter) -> Bool) -> String? {
        var offset: String.IndexDistance = 0
        var conditionResult: Bool = true
        
        repeat {
            let offsettedPosition = text.index(position, offsetBy: offset)
            
            guard offsettedPosition != text.endIndex else {
                return nil
            }
            
            let character = LexerCharacter(char: text[offsettedPosition])
            conditionResult = condition(character)
            
            if conditionResult == false {
                offset += 1
            }
        } while conditionResult
        
        return String(text.prefix(upTo: text.index(position, offsetBy: offset)))
    }
    
    private func peek() -> Character? {
        let char: [Character] = peek(count: 1)
        return char.first
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
        return extractAllAvoiding(chars: [.none, .newLine], limitAt: limit)
    }
    
    private func word(limitAt limit: LexerCharacter? = nil) -> String {
        return extractAllAvoiding(chars: [.none, .whitespace, .newLine], limitAt: limit)
    }
    
    private func findKeyword<T: GherkinKeyword & Findable>(trailingChar: Character? = nil) -> T? {
        /*if let trailingCharacter = trailingChar {
            if let possiblePeekedKeyword = peek(until: trailingCharacter) {
                return T.init(keyword: possiblePeekedKeyword)
            } else {
                return nil
            }
        }
        
        var peekCharacterCount = 1
        var residualPrimaryKeywords = T.keywords
        while residualPrimaryKeywords.count > 1 {
            residualPrimaryKeywords = residualPrimaryKeywords.filter {
                $0.starts(with: "\(currentChar.representation)\(peek(count: peekCharacterCount) ?? "")")
            }
            
            peekCharacterCount += 1
        }

        if residualPrimaryKeywords.count == 1 && peekCharacterCount > 1, let stringKeyword = residualPrimaryKeywords.first {
            return T(keyword: stringKeyword)
        }
        
        return nil*/
        guard let line = peek(until: { $0.isOne(of: [LexerCharacter.none, LexerCharacter.newLine]) }) else {
            return nil
        }
        
        let keywordsFound = T.keywords.filter { line.starts(with: $0) }
        
        switch keywordsFound.count {
        case 0: return nil
        case 1: return T(keyword: keywordsFound.first!)
        default:
            let sortByLength = keywordsFound.sorted { s1, s2 -> Bool in
                return s1.count > s2.count
            }
            
            return T(keyword: sortByLength.first!)
        }
    }
    
    func getNextToken() throws -> Token {
        while currentChar != .none {
            let location = currentLocation
            
            switch currentChar {
            case .whitespace:
                skip(characterSet: [.whitespace])
                
                continue
            case .newLine:
                if currentContext == .table {
                    currentContext = .none
                }
                
                skip(characterSet: [.newLine])
                
                continue
            case .comment:
                advance()
                
                return Token(Expression(content: sentence()), location)
            case .tag:
                if hasStillCharAhead {
                    advance()
                    return Token(SecondaryKeyword.tag(value: word()), location)
                } else {
                    return Token(Expression(content: String(LexerCharacter.tag.representation)), location)
                }
            case .pipe:
                advance()
                return Token(SecondaryKeyword.pipe, location)
            case .generic(_), .colon, .quotes:
                switch currentContext {
                case .table:
                    return Token(Expression(content: sentence(limitAt: LexerCharacter.pipe)), location)
                case .none:
                    if let primaryKeyword: PrimaryKeyword = findKeyword(trailingChar: ":") {
                        advance(positions: UInt(primaryKeyword.keyword.count))
                        advance() // colon
                        
                        return Token(primaryKeyword, location)
                    }
                    
                    if let secondaryKeyword: SecondaryKeyword = findKeyword() {
                        advance(positions: UInt(secondaryKeyword.keyword?.count ?? 0))
                        
                        return Token(secondaryKeyword, location)
                    }
                    
                    if let stepKeyword: StepKeyword = findKeyword() {
                        guard let keyword = stepKeyword.keyword else {
                            fatalError("This should not happen")
                        }
                        advance(positions: UInt(keyword.count))
                        
                        return Token(stepKeyword, location)
                    }
                    
                    return Token(Expression(content: sentence()), location)
                case .docString:
                    //TODO
                    return Token(Expression(content: ""), location)
                }
            case .tab:
                advance()
            case .none:
                fatalError("This should never happen")
            }
        }
        
        return Token(EOF(), currentLocation)
    }
    
    func parse() throws -> [Token] {
        let lastPosition = position
        
        position = text.startIndex
        
        var tokens: [Token] = []
        
        while true {
            let nextToken = try getNextToken()
            tokens.append(nextToken)
            
            if nextToken.type is EOF {
                break
            }
        }
        
        position = lastPosition
        
        return tokens
    }
    
}
