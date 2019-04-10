import Foundation

struct Line {
    
    enum LineType: String {
        case backgroundLine = "BackgroundLine"
        case comment = "Comment"
        case docStringSeparator = "DocStringSeparator"
        case empty = "Empty"
        case other = "Other"
        case examplesLine = "ExamplesLine"
        case featureLine = "FeatureLine"
        case language = "Language"
        case ruleLine = "RuleLine"
        case scenarioLine = "ScenarioLine"
        case stepLine = "StepLine"
        case tableRow = "TableRow"
        case tagLine = "TagLine"
        
        init?(token: TokenType?) {
            guard let inspectionToken = token else {
                return nil
            }
            
            switch inspectionToken {
            case .comment:
                self = .comment
            case .expression:
                self = .other
            case .language:
                self = .language
            case .keyword(let keyword):
                switch keyword {
                case is DocStringKeyword:
                    self = .docStringSeparator
                case is PrimaryKeyword:
                    switch keyword as! PrimaryKeyword {
                    case .examples:
                        self = .examplesLine
                    case .feature:
                        self = .featureLine
                    case .scenario, .scenarioOutline:
                        self = .scenarioLine
                    case .rule:
                        self = .ruleLine
                    case .background:
                        self = .backgroundLine
                    }
                case is SecondaryKeyword:
                    switch keyword as! SecondaryKeyword {
                    case .pipe:
                        self = .tableRow
                    case .tag:
                        self = .tagLine
                    }
                case is StepKeyword:
                    self = .stepLine
                default:
                    return nil
                }
            default:
                return nil
            }
        }
    }
    
    struct Item {
        let column: Int
        let text: String
    }
    
    let tokens: [Token]
    
    let type: LineType
    let keyword: Token?
    let text: String?
    let items: [Item]
    
    init?(tokens: [Token]) {
        self.tokens = tokens
        
        guard let firstToken = tokens.first else {
            return nil
        }
        
        type = LineType(token: firstToken.type) ?? .empty
        
        if case .keyword(_) = firstToken.type {
            keyword = firstToken
        } else {
            keyword = nil
        }
        
        if firstToken.isComment {
            text = tokens.stringValue
        } else {
            text = tokens.suffix(from: 1).stringValue
        }
        
        if firstToken.isPipeKeyword {
            items = tokens.filter({ $0.isExpression }).map {
                Item(column: $0.location.column, text: $0.value ?? "")
            }
        } else if firstToken.isTagToken {
            items = tokens.filter({ $0.isTagToken }).map {
                Item(column: $0.location.column, text: $0.value ?? "")
            }
        } else {
            items = []
        }
    }
    
    var formatToken: String {
        guard let location = location else {
            return ""
        }
        
        guard tokens.first?.type != .eof else {
            return "EOF\n"
        }
        
        let keywordIdentifier: String
        if let key = keyword {
            if key.isStepKeyword {
                keywordIdentifier = (key.value ?? "") + " "
            } else if key.isPrimaryKeyword {
                keywordIdentifier = (key.value ?? "").replacingOccurrences(of: ":", with: "")
            } else {
                keywordIdentifier = key.value ?? ""
            }
        } else {
            keywordIdentifier = ""
        }
        
        let outputPieces: [String] = [
            "(",
            String(location.line),
            ":",
            String(location.column),
            ")",
            type.rawValue,
            ":",
            keywordIdentifier,
            "/",
            (text ?? ""),
            "/",
            items.formatToken()
        ]
                
        return outputPieces.joined(separator: "")
    }
    
    fileprivate var location: Location? {
        return tokens.first?.location
    }
}

extension Collection where Element == Line.Item {
    
    fileprivate func formatToken() -> String {
        let line = map { "\($0.column):\($0.text)" }
        return line.joined(separator: ",")
    }
    
}

extension Collection where Element == Token {
    
    fileprivate var stringValue: String {
        return map({ $0.value ?? "" }).joined(separator: " ")
    }
    
}

class CucumberScanner {

    typealias TokensLine = [Token]
    
    let lexer: Lexer

    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func parseLines() throws -> [Int: Line] {
        let tokens = try lexer.parse()

        let rawLines: [TokensLine] = tokens.reduce(into: [TokensLine()]) { lines, token in
            guard let lastToken = lines.last?.last else {
                lines.append([token])
                return
            }
            
            if lastToken.location.line != token.location.line {
                lines.append([token])
            } else {
                var lastLine = lines.removeLast()
                lastLine.append(token)
                lines.append(lastLine)
            }
        }
        
        let rows = rawLines
            .compactMap { Line(tokens: $0) }
            .map { ($0.location?.line ?? -1, $0) }
        
        var dictionaryRows = Dictionary(uniqueKeysWithValues: rows)
        
        (1...(dictionaryRows.keys.max() ?? 1)).forEach { index in
            if !dictionaryRows.keys.contains(index) {
                dictionaryRows[index] = Line(tokens: [Token(.empty, Location(column: 1, line: index))])
            }
        }
        
        return dictionaryRows
    }
    
    func stringLines() throws -> String {
        let sortedLines = try parseLines().sorted { lineA, lineB in
            lineA.key < lineB.key
        }
        
        return sortedLines.map({ $0.value.formatToken }).joined(separator: "\n")
    }
    
}
