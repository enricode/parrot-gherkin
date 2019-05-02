import Foundation

class CucumberScanner: Scanner {

    struct ParseErrors: Error {
        private(set) var errors: [Error] = []
        
        mutating func add(error: Error) {
            errors.append(error)
        }
        
        var hasNoErrors: Bool {
            return errors.isEmpty
        }
    }

    typealias TokensLine = [Token]
    typealias InitializableLine = ScannerElementDescriptor & ScannerElementLineTokenInitializable
    
    let lexer: Lexer
    private let scannerFSM = ScannerFSM()
    private var parseErrors = ParseErrors()

    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func parseLines() -> Result<[Int: Scanner.Line], Error> {
        let tokens: [Token]
        do {
            tokens = try lexer.parse()
        } catch {
            parseErrors.add(error: error)
            return Result.failure(parseErrors)
        }

        let rawLines = tokensSplitByLines(with: tokens)
        
        let rows = rawLines
            .compactMap { parseLine(with: $0) }
            .map { ($0.location.line, $0) }
        
        guard parseErrors.hasNoErrors else {
            return Result.failure(parseErrors)
        }
        
        var dictionaryRows = Dictionary(uniqueKeysWithValues: rows)
        
        if !rows.isEmpty {
            (1...(dictionaryRows.keys.max() ?? 1)).forEach { index in
                if !dictionaryRows.keys.contains(index) {
                    dictionaryRows[index] = EmptyScannerElement(location: Location(column: 1, line: index))
                }
            }
        }
        
        return dictionaryRows.convertEmptyToOtherIfPreviousWasOtherType()
    }
    
    private func parseLine(with tokens: [Token]) -> Scanner.Line? {
        guard let firstToken = tokens.first else {
            return nil
        }
        
        let chainOfResponsibilityElements: [InitializableLine.Type] = [
            BackgroundLineScannerElement.self,
            ExamplesLineScannerElement.self,
            FeatureLineScannerElement.self,
            RuleLineScannerElement.self,
            ScenarioLineScannerElement.self,
            StepLineScannerElement.self,
            LanguageScannerElement.self,
            CommentScannerElement.self,
            DocStringSeparatorScannerElement.self,
            TagLineScannerElement.self,
            TableRowScannerElement.self,
            EOFScannerElement.self,
            OtherScannerElement.self // Leave as latest
        ]
        
        var scannerElement: Scanner.Line?
        
        for scannerElementType in chainOfResponsibilityElements {
            scannerElement = scannerElementType.init(tokens: tokens)
            
            if scannerElement != nil {
                break
            }
        }
        
        if let element = scannerElement {
            do {
                try scannerFSM.changeState(element: element as! ScannerElement)
            } catch {
                parseErrors.add(error: error)
            }
            return element
        } else {
            return EmptyScannerElement(location: firstToken.location)
        }
    }
    
    private func tokensSplitByLines(with tokens: [Token]) -> [TokensLine] {
        return tokens.reduce(into: [TokensLine()]) { lines, token in
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
    }
    
    func stringLines() -> Result<String, Error> {
        do {
            let sortedLines = try parseLines().get().sorted { lineA, lineB in
                lineA.key < lineB.key
            }
            
            var lines = sortedLines.map({ $0.value.elementDescription })
            
            if lines.last != "EOF" {
                lines.append("EOF")
            }
            
            return .success(lines.joined(separator: "\n") + "\n")
        } catch {
            return .failure(parseErrors)
        }
    }

}

extension Dictionary where Key == Int, Value == Scanner.Line {
    
    func convertEmptyToOtherIfPreviousWasOtherType() -> Result<[Int: Scanner.Line], Error> {
        var result = Dictionary<Int, Scanner.Line>()
        
        for (idx, line) in self where idx > 0 {
            if let emptyLine = line as? EmptyScannerElement,
                self[idx - 1] is OtherScannerElement {
                result[idx] = OtherScannerElement(text: "", location: emptyLine.location)
            } else {
                result[idx] = line
            }
        }
        
        return Result.success(result)
    }
    
}
