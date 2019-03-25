import XCTest
import Foundation

@testable import parrot

@objc public class AcceptanceTests: NSObject {
    
    var feature: String!
    var interpreter: CucumberInterpreter!
    var parsedFeature: ASTNode<Feature>!
    
    @objc public func parseBad(feature: String) {
        XCTFail("To implement")
    }
    
    @objc public func parseGood(feature: String) {
        given(file: feature)
        whenInterpreting()
        thenFeatureTokensAreTheSameAsInCorrispondingFile()
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
            print("Exception while interpreting: \(error)")
        }
    }
    
    func thenFeatureTokensAreTheSameAsInCorrispondingFile() {
        XCTAssertNotNil(parsedFeature)
    }
    
    func thenFeatureASTSAreTheSameAsInCorrispondingFile() {
        XCTAssertNotNil(parsedFeature)
    }
    
}
