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
    
    private func advance(positions: Int = 1) {
        position = text.index(position, offsetBy: positions)
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
    
    private func peek() -> Character? {
        let char: [Character] = peek(count: 1)
        return char.first
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
        
        while let char = currentChar, !char.isSpace && !char.isNewLine && !char.isColon {
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
        
        if nextIndex == text.endIndex && text.last != char {
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
    
    private func extractDocStringToken() throws -> Token {
        var result = ""
        
        while true {
            guard let current = currentChar else {
                throw LexerExceptions.unexpectedEOFWhileParsingDocString(docString: result)
            }
            
            if let peeked: String = peek(count: 2), "\(current)\(peeked)".isDocString {
                advance(positions: 3)
                break
            }
            
            result.append(current)
            advance()
        }
        
        var lines = result.split(separator: "\n").map(String.init)
        
        guard var firstLine = lines.first, let lastLine = lines.last, lastLine != firstLine else {
            return Token.docString(value: result)
        }
        
        if firstLine.trimmingCharacters(in: .whitespaces).isEmpty {
            lines = Array(lines.dropFirst())
            firstLine = lines[0]
        }
        if lastLine.trimmingCharacters(in: .whitespaces).isEmpty {
            lines = Array(lines.dropLast())
        }

        if let leadingWhitespaceCount = firstLine.index(where: { $0 != " " }) {
            let paddedLines: [Substring] = lines.map { line in
                guard let index = line.index(where: { $0 != " " }) else {
                    return line[line.startIndex...line.endIndex]
                }
                
                if index <= leadingWhitespaceCount {
                    return line.suffix(from: index)
                } else {
                    return line.suffix(from: leadingWhitespaceCount)
                }
            }
            let reconstructedDocString = paddedLines.map({ String($0) }).joined(separator: "\n")
            return Token.docString(value: reconstructedDocString)
        } else {
            return Token.docString(value: result)
        }
    }
    
    private func findKeyword(in word: String) -> Keyword? {
        if let scenarioKey = ScenarioKey(rawValue: word) {
            return scenarioKey
        }
        
        if let stepKeyword = StepKeyword(rawValue: word) {
            return stepKeyword
        }
        
        return nil
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
                if let peeked: String = peek(count: 2), "\(char)\(peeked)".isDocString {
                    advance(positions: 3)
                    return try extractDocStringToken()
                }
                
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
                
                if result == "Scenario", let outlineCandidate = try peek(until: ":") {
                    let outline = outlineCandidate == "Outline"
                    let template = outlineCandidate == "Template"
                    
                    if outline || template {
                        try advance(until: ":")
                        advance() // skip ':'
                        return Token.scenarioKey(outline ? .outline : .template)
                    }
                }

                if let colon = currentChar, colon == ":" {
                    if let scenarioKey = ScenarioKey(rawValue: result + String(colon)) {
                        advance()
                        return Token.scenarioKey(scenarioKey)
                    }
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
