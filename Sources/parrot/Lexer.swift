//
//  Lexer.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

enum LexerExceptions: Error {
    case cannotPeekUntilNotExistentChar(char: Character)
    case cannotAdvanceUntilNotExistentChar(char: Character)
}

class Lexer {
    
    let text: String
    private(set) var position: String.Index
    
    private var currentChar: Character?
    private var shouldCountWhitespaces = false
    private var skippedWhitespaces: Int = 0
    
    init(feature: String) {
        self.text = feature
        position = text.startIndex
        currentChar = text[position]
    }
    
    private var hasStillCharAhead: Bool {
        return position != text.endIndex
    }
    
    private func advance() {
        position = text.index(after: position)
        guard position != text.endIndex else {
            currentChar = nil
            return
        }
        currentChar = text[position]
    }
    
    private func advance(until char: Character, orEOF: Bool = false) throws {
        while let current = currentChar, current != char {
            advance()
        }
        
        if position == text.endIndex && currentChar != char && !orEOF {
            throw LexerExceptions.cannotAdvanceUntilNotExistentChar(char: char)
        }
    }
    
    private func peek() -> Character? {
        let nextIndex = text.index(after: position)
        guard nextIndex != text.endIndex else {
            return nil
        }
        return text[nextIndex]
    }
    
    private func skipWhitespaces() -> Int {
        var skipped = 0
        while let char = currentChar, char.isSpace {
            advance()
            skipped += 1
        }
        return skipped
    }
    
    private func sentence() throws -> String {
        var result = ""
        
        while let char = currentChar, !char.isNewLine {
            result.append(char)
            advance()
        }
        
        return result
    }
    
    func word() throws -> String {
        var result = ""
        
        while let char = currentChar, !char.isSpace && !char.isNewLine {
            result.append(char)
            advance()
        }
        
        return result
    }
    
    private func peek(until char: Character, stopAtNewLine: Bool = true) throws -> String? {
        var nextIndex = text.index(after: position)
        
        guard nextIndex != text.endIndex else {
            return nil
        }
        
        var nextWord: String = ""
        
        while nextIndex != text.endIndex, text[nextIndex] != char {
            if stopAtNewLine && text[nextIndex].isNewLine {
                break
            }
            nextWord.append(text[nextIndex])
            nextIndex = text.index(after: nextIndex)
        }
        
        if nextIndex == text.endIndex && text[text.endIndex] != char {
            throw LexerExceptions.cannotPeekUntilNotExistentChar(char: char)
        }
        
        if nextWord.isEmpty {
            return nil
        } else {
            return nextWord
        }
    }
    
    private func peekWord() throws -> String? {
        return try peek(until: " ")
    }
    
    func getNextToken() throws -> Token {
        while let char = currentChar {
            
            if char.isSpace {
                let skipped = skipWhitespaces()
                
                if shouldCountWhitespaces {
                    skippedWhitespaces += skipped
                }
                
                continue
            } else {
                shouldCountWhitespaces = true
                
                if skippedWhitespaces > 0 {
                    let skipped = skippedWhitespaces
                    skippedWhitespaces = 0
                    return Token.whitespaces(count: skipped)
                }
            }
            
            if char.isCommentChar {
                try advance(until: "\n", orEOF: true)
                if hasStillCharAhead {
                    advance()
                    return Token.newLine
                } else {
                    return Token.EOF
                }
            }
            
            if char.isNewLine {
                shouldCountWhitespaces = false
                advance()
                return Token.newLine
            }
            
            if char.isTagChar && hasStillCharAhead {
                advance()
                let tag = try word()
                return Token.tag(value: tag)
            }
            
            if char.isPipe {
                advance()
                return Token.pipe
            }
            
            if char.isColon {
                advance()
                return Token.colon
            }
            
            if (char.isParameterOpen || char.isExampleParameterOpen) && hasStillCharAhead {
                do {
                    if char.isExampleParameterOpen, let parameter = try peek(until: ">") {
                        try advance(until: ">")
                        advance()
                        return Token.exampleParameter(value: parameter)
                    } else if char.isParameterOpen, let parameter = try peek(until: "\"") {
                        advance()
                        try advance(until: "\"")
                        advance()
                        return Token.parameter(value: parameter)
                    }
                } catch {
                    // Just continue as a word
                }
            }
            
            if char.isntSpace {
                let result = try word()
                
                if let scenarioKey = ScenarioKey(rawValue: result) {
                    return Token.scenarioKey(scenarioKey)
                }
                
                if let stepKeyword = StepKeyword(rawValue: result) {
                    return Token.stepKeyword(stepKeyword)
                }
                
                return Token.word(value: result)
            }
        }
        
        return Token.EOF
    }
    
    func parse() throws -> [Token] {
        let lastPosition = position
        
        position = text.startIndex
        
        var tokens: [Token] = []
        
        while true {
            let nextToken = try getNextToken()
            tokens.append(nextToken)
            
            if nextToken == .EOF {
                break
            }
        }
        
        position = lastPosition
        
        return tokens
    }
    
}
