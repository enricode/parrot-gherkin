import Foundation

class TokenExporter {
    
    let lexer: Lexer
    private var currentToken: Token
    
    init(lexer: Lexer) throws {
        self.lexer = lexer
        currentToken = try lexer.getNextToken()
    }
    
    func export() throws -> String {
        var lastLineNumber = currentToken.location.line
        var line = try getLine()
        var result = ""
        
        while !line.isEmpty {
            result += line.getTokenLine() + "\n"
            
            if currentToken.location.line != lastLineNumber {
                (1..<currentToken.location.line - lastLineNumber).forEach { line in
                    result += "(\(lastLineNumber + line):1)Empty://" + "\n"
                }
            }
            
            lastLineNumber = currentToken.location.line
            line = try getLine()
        }
        
        result.append("EOF\n")
        
        return result
    }
    
    private func getLine() throws -> [Token] {
        let initialLine = currentToken.location.line
        var tokens: [Token] = []
        
        while !currentToken.isEOF && currentToken.location.line == initialLine {
            tokens.append(currentToken)
            currentToken = try lexer.getNextToken()
        }
        
        return tokens
    }
    
}

extension Collection where Element == Token {
    
    fileprivate func getTokenLine() -> String {
        return reduce("") { line, token in
            var tokenDescription = ""
            
            if let first = first, first == token {
                tokenDescription += token.location.prettyPrint
                tokenDescription += token.lineDescription + ":"
            }
            
            tokenDescription += token.tokenValue
            
            return line + tokenDescription + "/"
        }
    }
    
}

extension Token {
    
    fileprivate var lineDescription: String {
        switch type {
        case .comment: return "Comment"
        case .eof: return "EOF"
        case .empty: return ""
        case .expression: return "Other"
        case .keyword(let keyword):
            switch keyword {
            case is PrimaryKeyword:
                switch keyword as! PrimaryKeyword {
                case .background: return "BackgroundLine"
                case .examples: return "ExamplesLine"
                case .feature: return "FeatureLine"
                case .rule: return "RuleLine"
                case .scenario, .scenarioOutline: return "ScenarioLine"
                }
            case is SecondaryKeyword:
                switch keyword as! SecondaryKeyword {
                case .pipe: return "TableRow"
                case .tag: return "TagLine"
                }
            case is StepKeyword:
                return "StepLine"
            default:
                return "Other"
            }
        case .language: return "Language"
        }
    }
    
    fileprivate var tokenValue: String {
        let stringValue = value ?? ""
        
        switch type {
        case .comment: return stringValue
        case .empty: return ""
        case .eof: return stringValue
        case .expression: return stringValue
        case .keyword(let keyword):
            switch keyword {
            case is PrimaryKeyword:
                return stringValue.replacingOccurrences(of: ":", with: "")
            case is SecondaryKeyword:
                switch keyword as! SecondaryKeyword {
                case .pipe: return "TableRow"
                case .tag: return "\(location.column):\(stringValue)"
                }
            case is StepKeyword:
                return stringValue + " "
            default:
                return "Other"
            }
        case .language: return "Language"
        }
    }
}
