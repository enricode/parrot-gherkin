import Foundation

class CucumberScanner: Scanner {

    typealias TokensLine = [Token]
    typealias InitializableLine = ScannerElementDescriptor & ScannerElementLineTokenInitializable
    
    let lexer: Lexer
    private let scannerFSM = ScannerFSM()
    private var parseError = ParseError()

    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func parseLines() -> Result<[Int: Scanner.Line], ParseError> {
        let tokens: [Token]
        do {
            tokens = try lexer.parse()
        } catch LanguageDictionaryInitException.invalidLanguage(let language) {
            let location = Location.start.firstColumn
            parseError.add(error: ExportableError(
                data: "\(location.prettyPrint): Language not supported: \(language)",
                source: Source(location: location, uri: lexer.uri?.absoluteString ?? "")
            ))
            return Result.failure(parseError)
        } catch {
            print("Unhandled error: \(error)")
            return Result.failure(parseError)
        }

        let rawLines = tokensSplitByLines(with: tokens)
        
        var scannerElements = rawLines.compactMap { parseLine(with: $0) }
        if !(scannerElements.last is EOFScannerElement) {
            scannerElements.append(EOFScannerElement(
                location: scannerElements.last?.location.newLine ?? Location(column: 0, line: 1)
            ))
        }
        let rows = scannerElements.map { ($0.location.line, $0) }
        
        guard parseError.hasNoErrors else {
            return Result.failure(parseError)
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
            } catch let error as ScannerError {
                parseError.add(error: ExportableError(
                    data: error.localizedDescription,
                    source: Source(location: error.location, uri: lexer.uri?.absoluteString ?? "")
                ))
            } catch {
                print("Unhandled error: \(error)")
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
    
    func stringLines() -> Result<String, ParseError> {
        do {
            let sortedLines = try parseLines().get().sorted { lineA, lineB in
                lineA.key < lineB.key
            }
            
            let lines = sortedLines.map({ $0.value.elementDescription })
            
            return .success(lines.joined(separator: "\n") + "\n")
        } catch {
            return .failure(parseError)
        }
    }

}

extension Dictionary where Key == Int, Value == Scanner.Line {
    
    func convertEmptyToOtherIfPreviousWasOtherType() -> Result<[Int: Scanner.Line], ParseError> {
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
