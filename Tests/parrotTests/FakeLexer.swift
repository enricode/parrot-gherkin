import Foundation
@testable import parrot
/*
class FakeLexer: Lexer {
    let text: String
    let tokens: [Token]
    
    private var index: Int = 0
    
    init(text: String) {
        self.text = text
        self.tokens = []
    }
    
    init(tokens: [Token]) {
        self.text = ""
        self.tokens = tokens
    }
    
    func parse() throws -> [Token] {
        return tokens
    }
    
    func getNextToken() throws -> Token {
        guard index < tokens.endIndex else {
            return .EOF
        }
        index += 1
        return tokens[index - 1]
    }
    
    var feature: String {
        do {
            let tokens = try parse()
            
            return tokens.reduce("") { result, token in
                return result + token.representation
            }
        } catch {
            return "Failed to reconstruct feature content: \(error)"
        }
    }
}
*/
