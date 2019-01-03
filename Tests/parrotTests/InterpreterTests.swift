import XCTest
@testable import parrot

final class InterpreterTests: XCTestCase {
    
    var interpreter: CucumberInterpreter!
    var error: ParrotError!
    var feature: AST!
    
    override func setUp() {
        interpreter = nil
        error = nil
        feature = nil
    }
    
    func testIncompleteFeature() {
        given(input: [
            Token.scenarioKey(.feature),
            Token.word(value: "Hello world"),
            Token.EOF
        ])
        whenInterpreting()
        thenErrorCatched(is: InterpreterException.unexpectedTerm(term: Token.EOF.descriptionValue, expected: "Scenario:, Example:, Scenario Outline:, Scenario Template:"))
    }
    
    func testScenarioOutlineWithoutExamples() {
        given(input:
            featureTokens() +
            scenarioOutlineTokens() +
            givenStepTokens() +
            [Token.pipe, Token.word(value: "Header col"), Token.pipe] +
            [Token.EOF]
        )
        whenInterpreting()
        thenErrorCatched(is: InterpreterException.scenarioOutlineWithoutExamples)
    }
    
    func featureTokens(named: String = "Feature name") -> [Token] {
        return [
            Token.scenarioKey(.feature),
            Token.word(value: named),
            Token.newLine
        ]
    }
    
    func scenarioOutlineTokens() -> [Token] {
        return [
            Token.scenarioKey(.outline),
            Token.word(value: "Scenario outline title"),
            Token.newLine
        ]
    }
    
    func givenStepTokens() -> [Token] {
        return [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "something"),
            Token.newLine
        ]
    }
    
    private func given(input: [Token]) {
        do {
            interpreter = try CucumberInterpreter(lexer: FakeLexer(tokens: input))
        } catch {
            XCTFail("Cannot instance cucumber interpreter")
        }
    }
    
    private func whenInterpreting() {
        do {
            feature = try interpreter.parse()
        } catch {
            self.error = error as! ParrotError
        }
    }
    
    private func thenErrorCatched(is error: ParrotError) {
        XCTAssert(self.error.isSameError(as: error), "Error \(self.error) is not the same as \(error)")
    }
    
    static var allTests = [
        ("testIncompleteFeature", testIncompleteFeature)
    ]
}
