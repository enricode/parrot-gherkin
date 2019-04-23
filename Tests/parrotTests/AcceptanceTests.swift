import XCTest
import Foundation

@testable import parrot

@objc public class AcceptanceTests: NSObject {
    
    var feature: TestFeature!
    var exportedTokens: String!
    var interpreter: CucumberInterpreter!
    var parsedFeature: ASTNode<Feature>!
    var error: Error!
    
    @objc public func parseBad(feature: String) {
        given(file: feature)
        
        whenExportingLexes()
        thenExportedTokensAreVoid()
        
        /*whenInterpreting()
        thenErrorsAreSameAsJSONs()
        thenParsedFeatureIsNil()*/
    }
    
    @objc public func parseGood(feature: String) {
        given(file: feature)
        whenExportingLexes()
        thenFeatureTokensAreTheSameAsInCorrispondingFile()
        /*whenInterpreting()
        thenFeatureASTSAreTheSameAsInCorrispondingFile()*/
    }
    
    func given(file: String) {
        feature = TestFeature(path: file)
    }
    
    func whenInterpreting() {
        do {
            interpreter = try CucumberInterpreter(lexer: CucumberLexer(feature: feature.content))
            parsedFeature = try interpreter.parse()
        } catch {
            self.error = error
            print("Exception while interpreting: \(error)")
        }
    }
    
    func whenExportingLexes() {
        do {
            let cucumberScanner = CucumberScanner(lexer: CucumberLexer(feature: feature.content))
            exportedTokens = try cucumberScanner.stringLines()
        } catch {
            print("Exception while exporting tokens")
        }
    }
    
    func thenExportedTokensAreVoid() {
        XCTAssertNil(exportedTokens)
    }
    
    func thenFeatureTokensAreTheSameAsInCorrispondingFile() {
        XCTAssertEqual(feature.tokens, exportedTokens, comparedStrings(stringA: feature.tokens, stringB: exportedTokens))
    }
    
    func thenFeatureASTSAreTheSameAsInCorrispondingFile() {
        XCTAssertNil(error)
    }
    
    func thenErrorsAreSameAsJSONs() {
        // TBD
    }
    
    func thenParsedFeatureIsNil() {
        
    }
    
    func comparedStrings(stringA: String, stringB: String) -> String {
        let comparison = zip(stringA.split(separator: "\n"), stringB.split(separator: "\n")).reduce("", { error, pair in
            return error + "A: \(pair.0)\nB: \(pair.1)\n\n"
        })
        
        return "\n\n - Compared tokens --------------\n" + comparison
    }
}
