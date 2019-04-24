import Foundation

class CucumberScanner {

    typealias TokensLine = [Token]
    typealias Line = ScannerElementDescriptor
    typealias InitializableLine = ScannerElementDescriptor & ScannerElementLineTokenInitializable
    
    let lexer: Lexer

    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func parseLines() throws -> [Int: Line] {
        let tokens = try lexer.parse()

        let rawLines = tokensSplitByLines(with: tokens)
        
        let rows = rawLines
            .compactMap { parseLine(with: $0) }
            .map { ($0.location.line, $0) }
        
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
    
    private func parseLine(with tokens: [Token]) -> Line? {
        guard let firstToken = tokens.first, !firstToken.isEOF else {
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
            OtherScannerElement.self // Leave as latest
        ]
        
        var scannerElement: Line?
        
        for scannerElementType in chainOfResponsibilityElements {
            scannerElement = scannerElementType.init(tokens: tokens)
            
            if scannerElement != nil {
                break
            }
        }
        
        return scannerElement ?? EmptyScannerElement(location: firstToken.location)
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
    
    func stringLines() throws -> String {
        let sortedLines = try parseLines().sorted { lineA, lineB in
            lineA.key < lineB.key
        }
        
        let lines = sortedLines.map({ $0.value.elementDescription }) + ["EOF"]
        
        return lines.joined(separator: "\n") + "\n"
    }
    
}

extension Dictionary where Key == Int, Value == CucumberScanner.Line {
    
    func convertEmptyToOtherIfPreviousWasOtherType() -> Dictionary<Int, CucumberScanner.Line> {
        var result = Dictionary<Int, CucumberScanner.Line>()
        
        for (idx, line) in self where idx > 0 {
            if let emptyLine = line as? EmptyScannerElement,
                self[idx - 1] is OtherScannerElement {
                result[idx] = OtherScannerElement(text: "", location: emptyLine.location)
            } else {
                result[idx] = line
            }
        }
        
        return result
    }
    
}
