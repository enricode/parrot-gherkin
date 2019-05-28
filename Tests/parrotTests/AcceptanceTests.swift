import XCTest
import Foundation

@testable import parrot

@objc public class AcceptanceTests: NSObject {
    
    var feature: TestFeature!
    var parseResult: Result<String, ParseError>! {
        didSet {
            guard let result = parseResult else {
                return
            }
            switch result {
            case .failure(let error):
                errors = error.errors
            case .success(let parsed):
                exportedTokens = parsed
            }
        }
    }
    var exportedTokens: String!
    var error: Error!
    var errors: [ExportableError]!
    var interpreter: CucumberInterpreter!
    var parsedFeature: ASTNode<Feature>!
    
    @objc public func parseBad(feature: String) {
        given(file: feature)
        whenExportingLexes()
        thenExportedTokensAreVoid()
        thenErrorsAreSameAsJSONs()
        
        whenInterpreting()
        thenParsedFeatureIsNil()
    }
    
    @objc public func parseGood(feature: String) {
        given(file: feature)
        whenExportingLexes()
        thenFeatureTokensAreTheSameAsInCorrispondingFile()
        whenInterpreting()
        thenThereAreNoErrors()
        thenFeatureASTIsSameAsJSON()
    }
    
    func given(file: String) {
        feature = TestFeature(path: file)
    }
    
    func whenInterpreting() {
        do {
            interpreter = try CucumberInterpreter(scanner: CucumberScanner(lexer: CucumberLexer(feature: feature.content)))
            parsedFeature = try interpreter.parse()
        } catch {
            self.error = error
            print("Exception while interpreting: \(error)")
        }
    }
    
    func whenExportingLexes() {
        let cucumberScanner = CucumberScanner(lexer: CucumberLexer(feature: feature.content))
        parseResult = cucumberScanner.stringLines()
    }
    
    func thenExportedTokensAreVoid() {
        XCTAssertNil(exportedTokens)
    }
    
    func thenFeatureTokensAreTheSameAsInCorrispondingFile() {
        XCTAssertEqual(feature.tokens, exportedTokens, comparedStrings(stringA: feature.tokens, stringB: exportedTokens))
    }
    
    func thenErrorsAreSameAsJSONs() {
        XCTAssertNotNil(errors)
        XCTAssertFalse(errors.isEmpty, "Errors is empty")
        XCTAssertEqual(feature.exportedErrors, errors)
    }
    
    func thenThereAreNoErrors() {
        XCTAssertNil(errors)
    }
    
    func thenParsedFeatureIsNil() {
        XCTAssertNil(feature)
    }
    
    func thenFeatureASTIsSameAsJSON() {
        
    }
    
    func comparedStrings(stringA: String, stringB: String) -> String {
        let comparison = zip(stringA.split(separator: "("), stringB.split(separator: "(")).reduce("", { error, pair in
            return error + "A: (\(pair.0)B: (\(pair.1)\n\n"
        })
        
        return "\n\n - Compared tokens --------------\n" + comparison
    }
}
