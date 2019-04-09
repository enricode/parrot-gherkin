import XCTest
import Foundation

@testable import parrot

@objc public class AcceptanceTests: NSObject {
    
    var feature: String!
    var exportedTokens: String!
    var interpreter: CucumberInterpreter!
    var parsedFeature: ASTNode<Feature>!
    var error: Error!
    
    @objc public func parseBad(feature: String) {
        given(file: feature)
        
        whenExportingLexes()
        thenExportedTokensAreVoid()
        
        whenInterpreting()
        thenErrorsAreSameAsJSONs()
        thenParsedFeatureIsNil()
    }
    
    @objc public func parseGood(feature: String) {
        given(file: feature)
        whenExportingLexes()
        thenFeatureTokensAreTheSameAsInCorrispondingFile()
        whenInterpreting()
        thenFeatureASTSAreTheSameAsInCorrispondingFile()
    }
    
    func given(file: String) {
        do {
            feature = try String(contentsOfFile: file)
        } catch {
            XCTFail("Cannot read feature.")
        }
    }
    
    func whenInterpreting() {
        do {
            interpreter = try CucumberInterpreter(lexer: CucumberLexer(feature: feature))
            parsedFeature = try interpreter.parse()
        } catch {
            self.error = error
            print("Exception while interpreting: \(error)")
        }
    }
    
    func whenExportingLexes() {
        do {
            let tokenExporter = try TokenExporter(lexer: CucumberLexer(feature: feature))
            exportedTokens = try tokenExporter.export()
            exportedTokens!.split(separator: "\n").forEach({ print($0) })
        } catch {
            print("Exception while exporting tokens")
        }
    }
    
    func thenExportedTokensAreVoid() {
        XCTAssertNil(exportedTokens)
    }
    
    func thenFeatureTokensAreTheSameAsInCorrispondingFile() {
        
    }
    
    func thenFeatureASTSAreTheSameAsInCorrispondingFile() {
        XCTAssertNil(error)
    }
    
    func thenErrorsAreSameAsJSONs() {
        // TBD
    }
    
    func thenParsedFeatureIsNil() {
        
    }
}
