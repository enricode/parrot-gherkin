import XCTest
import Foundation

@testable import parrot

final class FunctionalTests: NSObject {
    
    var feature: String!
    var interpreter: CucumberInterpreter!
    var parsedFeature: ASTNode<Feature>!
    
    @objc func parseGood(feature: String) {
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
            
        }
    }
    
    func thenFeatureTokensAreTheSameAsInCorrispondingFile() {
        XCTFail("Implement me")
    }
    
    func thenFeatureASTSAreTheSameAsInCorrispondingFile() {
        XCTFail("Implement me")
    }
    
}
