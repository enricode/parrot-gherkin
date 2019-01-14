import XCTest
@testable import parrot

final class LexerTests: XCTestCase {
    
    var lexer: CucumberLexer!
    var tokens: [Token]!
    
    override func setUp() {
        lexer = nil
    }
    
    func testIgnoresWhitespaces() {
        given(input: "     Hello   World   ")
        whenLexing()
        thenTokens(are: [
            Token.word(value: "Hello"),
            Token.whitespaces(count: 3),
            Token.word(value: "World"),
            Token.EOF
        ])
    }
    
    func testNewLines() {
        given(input: "\n\nFeature: A\n  Given\n")
        whenLexing()
        thenTokens(are: [
            Token.newLine,
            Token.newLine,
            Token.scenarioKey(.feature),
            Token.whitespaces(count: 1),
            Token.word(value: "A"),
            Token.newLine,
            Token.stepKeyword(.given),
            Token.newLine,
            Token.EOF
        ])
    }
    
    func testSplitKeywordsWithoutWhitespaces() {
        given(input: "Feature:Hello")
        whenLexing()
        thenTokens(are: [Token.scenarioKey(.feature), Token.word(value: "Hello"), Token.EOF])
    }
    
    func testAdvanceWithFinalColon() {
        given(input: "Feature:")
        whenLexing()
        thenTokens(are: [Token.scenarioKey(.feature), Token.EOF])
    }
    
    func testDocString() {
        given(input: """
            Given something_with_doc_string
              \"\"\"
              with first line indented like this
                it should preserve two spaces
                 and now three
              \"\"\"
            """)
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "something_with_doc_string"),
            Token.newLine,
            Token.docString(value: "with first line indented like this\n  it should preserve two spaces\n   and now three"),
            Token.EOF
        ])
    }
    
    func testTags() {
        given(input: "@tag1 @tag2\nFeature: Hello")
        whenLexing()
        thenTokens(are: [
            Token.tag(value: "tag1"),
            Token.whitespaces(count: 1),
            Token.tag(value: "tag2"),
            Token.newLine,
            Token.scenarioKey(.feature),
            Token.whitespaces(count: 1),
            Token.word(value: "Hello"),
            Token.EOF
        ])
    }
    
    func testGivenWhenThen() {
        given(input: "Given hello\nWhen action\nThen happiness")
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "hello"),
            Token.newLine,
            Token.stepKeyword(.when),
            Token.whitespaces(count: 1),
            Token.word(value: "action"),
            Token.newLine,
            Token.stepKeyword(.then),
            Token.whitespaces(count: 1),
            Token.word(value: "happiness"),
            Token.EOF
        ])
    }
    
    func testTitleAndDescription() {
        given(input: """
            Scenario Outline: Title of scenario
                              Description of scenario
                Given initial condition
            """)
        whenLexing()
        thenTokens(are: [
            Token.scenarioKey(.outline),
            Token.whitespaces(count: 1),
            Token.word(value: "Title"),
            Token.whitespaces(count: 1),
            Token.word(value: "of"),
            Token.whitespaces(count: 1),
            Token.word(value: "scenario"),
            Token.newLine,
            Token.word(value: "Description"),
            Token.whitespaces(count: 1),
            Token.word(value: "of"),
            Token.whitespaces(count: 1),
            Token.word(value: "scenario"),
            Token.newLine,
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "initial"),
            Token.whitespaces(count: 1),
            Token.word(value: "condition"),
            Token.EOF
        ])
    }
    
    func testScenarioOutline() {
        given(input: "Scenario Outline:")
        whenLexing()
        thenTokens(are: [
            Token.scenarioKey(.outline),
            Token.EOF
        ])
    }
    
    func testScenarioTemplate() {
        given(input: "Scenario Template:")
        whenLexing()
        thenTokens(are: [
            Token.scenarioKey(.template),
            Token.EOF
        ])
    }

    func testExample() {
        given(input: "Example:")
        whenLexing()
        thenTokens(are: [
            Token.scenarioKey(.example),
            Token.EOF
        ])
    }
    
    func testComments() {
        given(input: """
            # this is a comment

            Feature: A
            
            # another comment
            Scenario: Hello
                Given this
            # a step comment
            """)
        whenLexing()
        thenTokens(are: [
            Token.newLine,
            Token.newLine,
            Token.scenarioKey(.feature),
            Token.whitespaces(count: 1),
            Token.word(value: "A"),
            Token.newLine,
            Token.newLine,
            Token.newLine,
            Token.scenarioKey(.scenario),
            Token.whitespaces(count: 1),
            Token.word(value: "Hello"),
            Token.newLine,
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "this"),
            Token.newLine,
            Token.EOF
        ])
    }
    
    func testDataTable() {
        given(input: """
            Given this table:
                | title_of_column |
                | data1           |
                | data2           |
            """)
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: "this"),
            Token.whitespaces(count: 1),
            Token.word(value: "table"),
            Token.colon,
            Token.newLine,
            
            Token.pipe,
            Token.whitespaces(count: 1),
            Token.word(value: "title_of_column"),
            Token.whitespaces(count: 1),
            Token.pipe,
            Token.newLine,
            
            Token.pipe,
            Token.whitespaces(count: 1),
            Token.word(value: "data1"),
            Token.whitespaces(count: 11),
            Token.pipe,
            Token.newLine,
            
            Token.pipe,
            Token.whitespaces(count: 1),
            Token.word(value: "data2"),
            Token.whitespaces(count: 11),
            Token.pipe,
            
            Token.EOF
        ])
    }
    
    func testExampleParameter() {
        given(input: "Given <param>")
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.exampleParameter(value: "param"),
            Token.EOF
        ])
    }
    
    func testParameter() {
        given(input: "Given \"param\"")
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.parameter(value: "param"),
            Token.EOF
        ])
    }
    
    func testExampleParameterInParameter() {
        given(input: "Given \"<param>\"")
        whenLexing()
        thenTokens(are: [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.parameter(value: "<param>"),
            Token.EOF
        ])
    }
    
    private func given(input: String) {
        lexer = CucumberLexer(feature: input)
    }
    
    private func whenLexing() {
        do {
            tokens = try lexer.parse()
        } catch {
            XCTFail("Exception raised: \(error)")
        }
    }
    
    private func thenTokens(are expectedTokens: [Token]) {
        if tokens != expectedTokens {
            print("   EXPECTED".padded + "    ACTUAL".padded)
            for (index, token) in zip(expectedTokens, tokens).enumerated() {
                print("\(index): \(token.0.padded) \(token.1.padded)")
            }
        }
        
        XCTAssertEqual(tokens, expectedTokens)
    }
    
    static var allTests = [
        ("testIgnoresWhitespaces", testIgnoresWhitespaces),
        ("testNewLines", testNewLines),
        ("testTags", testTags),
        ("testGivenWhenThen", testGivenWhenThen),
        ("testTitleAndDescription", testTitleAndDescription),
        ("testComments", testComments),
        ("testDataTable", testDataTable),
        ("testExampleParameter", testExampleParameter),
        ("testParameter", testParameter)
    ]
}
