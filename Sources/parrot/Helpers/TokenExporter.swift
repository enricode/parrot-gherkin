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
            
            (1..<currentToken.location.line - lastLineNumber).forEach { line in
                result += "(\(lastLineNumber + line):1)Empty://" + "\n"
            }
            
            lastLineNumber = currentToken.location.line
            line = try getLine()
        }
        
        result.append("EOF")
        
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
                tokenDescription += token.lineNumber
                tokenDescription += token.lineDescription + ":"
            }
            
            tokenDescription += token.value ?? ""
            
            return line + tokenDescription + "/"
        }
    }
    
}

extension Token {
    
    fileprivate var lineNumber: String {
        return "(\(location.line):\(location.column))"
    }
    
    fileprivate var lineDescription: String {
        switch type {
        case .comment: return "Comment"
        case .eof: return "EOF"
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
}

/*
 (1:1)FeatureLine:Feature/DataTables/
 (2:1)Empty://
 (3:3)ScenarioLine:Scenario/minimalistic/
 (4:5)StepLine:Given /a simple data table/
 (5:7)TableRow://9:foo,15:bar
 (6:7)TableRow://9:boz,15:boo
 (7:5)StepLine:And /a data table with a single cell/
 (8:7)TableRow://9:foo
 (9:5)StepLine:And /a data table with different fromatting/
 (10:7)TableRow://11:foo,15:bar,23:boz
 (11:5)StepLine:And /a data table with an empty cell/
 (12:7)TableRow://8:foo,12:,13:boz
 (13:5)StepLine:And /a data table with comments and newlines inside/
 (14:7)TableRow://9:foo,15:bar
 (15:1)Empty://
 (16:7)TableRow://9:boz,16:boo
 (17:1)Comment:/      # this is a comment/
 (18:7)TableRow://9:boz2,16:boo2
 EOF

 */
