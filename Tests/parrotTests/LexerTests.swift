import XCTest
@testable import parrot

final class LexerTests: XCTestCase {
    
    var lexer: CucumberLexer!
    var tokens: [Token]!
    
    override func setUp() {
        lexer = nil
    }
    
    func testIgnoresHeadingAndTrailingWhitespaces() {
        given(input: "     Hello   World   ")
        whenLexing()
        thenTokens(are: [
            Token(Expression(content: "Hello   World"), Location(column: 6, line: 1)),
            Token(EOF(), Location(column: 22, line: 1))
        ])
    }
    
    func testNewLines() {
        given(input: "\n\nFeature: A\n  Given\n")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.feature, Location(column: 1, line: 3)),
            Token(Expression(content: "A"), Location(column: 10, line: 3)),
            Token(PrimaryKeyword.given, Location(column: 3, line: 4)),
            Token(EOF(), Location(column: 3, line: 5))
        ])
    }
    
    func testSplitKeywordsWithoutWhitespaces() {
        given(input: "Feature:Hello")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.feature, Location(column: 1, line: 1)),
            Token(Expression(content: "Hello"), Location(column: 9, line: 1)),
            Token(EOF(), Location(column: 14, line: 1))
        ])
    }
    
    func testAdvanceWithFinalColon() {
        given(input: "Feature:")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.feature, Location(column: 1, line: 1)),
            Token(EOF(), Location(column: 9, line: 1))
        ])
    }
    
    func testDocString() {
        given(input: """
            Given something with doc string
              \"\"\"type
              with first line indented like this
                it should preserve two spaces
                 and now three
              \"\"\"
            """)
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.given, Location(column: 1, line: 1)),
            Token(Expression(content: "something with doc string"), Location(column: 7, line: 1)),
            Token(SecondaryKeyword.docStrings, Location(column: 3, line: 2)),
            Token(Expression(content: "with first line indented like this"), Location(column: 3, line: 3)),
            Token(Expression(content: "it should preserve two spaces"), Location(column: 5, line: 4)),
            Token(Expression(content: "and now three"), Location(column: 5, line: 6)),
            Token(SecondaryKeyword.docStrings, Location(column: 6, line: 3)),
            Token(EOF(), Location(column: 9, line: 1))
        ])
    }
    
    func testTags() {
        given(input: "@tag1 @tag2\nFeature: Hello")
        whenLexing()
        thenTokens(are: [
            Token(SecondaryKeyword.tag(value: "tag1"), Location(column: 1, line: 1)),
            Token(SecondaryKeyword.tag(value: "tag2"), Location(column: 7, line: 1)),
            Token(PrimaryKeyword.feature, Location(column: 1, line: 2)),
            Token(Expression(content: "Hello"), Location(column: 10, line: 2)),
            Token(EOF(), Location(column: 15, line: 2))
        ])
    }
    
    func testGivenWhenThen() {
        given(input: "Given hello\nWhen action\nThen happiness")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.given, Location(column: 1, line: 1)),
            Token(Expression(content: "hello"), Location(column: 7, line: 1)),
            Token(PrimaryKeyword.when, Location(column: 1, line: 2)),
            Token(Expression(content: "action"), Location(column: 6, line: 2)),
            Token(PrimaryKeyword.then, Location(column: 1, line: 3)),
            Token(Expression(content: "happiness"), Location(column: 6, line: 3)),
            Token(EOF(), Location(column: 15, line: 3))
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
            Token(PrimaryKeyword.scenarioOutline, Location(column: 1, line: 1)),
            Token(Expression(content: "Title of scenario"), Location(column: 19, line: 1)),
            Token(Expression(content: "Description of scenario"), Location(column: 19, line: 2)),
            Token(PrimaryKeyword.given, Location(column: 5, line: 3)),
            Token(Expression(content: "initial condition"), Location(column: 11, line: 3)),
            Token(EOF(), Location(column: 28, line: 3))
        ])
    }
    
    func testScenarioOutline() {
        given(input: "Scenario Outline:")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.scenarioOutline, Location(column: 1, line: 1)),
            Token(EOF(), Location(column: 18, line: 1))
        ])
    }
    
    func testScenarioTemplate() {
        given(input: "Scenario Template:")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.scenarioOutline, Location(column: 1, line: 1)),
            Token(EOF(), Location(column: 19, line: 1))
        ])
    }

    func testExample() {
        given(input: "Example:")
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.scenario, Location(column: 1, line: 1)),
            Token(EOF(), Location(column: 9, line: 1))
        ])
    }
    
    func testComments() {
        given(input: """
            # this is a comment

            Feature: A
            
            #another comment
            Scenario: Hello
                Given this
            # a step comment
            """)
        whenLexing()
        thenTokens(are: [
            Token(SecondaryKeyword.comment, Location(column: 1, line: 1)),
            Token(Expression(content: "this is a comment"), Location(column: 3, line: 1)),
            Token(PrimaryKeyword.feature, Location(column: 1, line: 3)),
            Token(Expression(content: "A"), Location(column: 10, line: 3)),
            Token(SecondaryKeyword.comment, Location(column: 5, line: 1)),
            Token(Expression(content: "another comment"), Location(column: 2, line: 5)),
            Token(PrimaryKeyword.scenario, Location(column: 1, line: 6)),
            Token(Expression(content: "Hello"), Location(column: 11, line: 6)),
            Token(PrimaryKeyword.given, Location(column: 5, line: 7)),
            Token(Expression(content: "this"), Location(column: 11, line: 7)),
            Token(SecondaryKeyword.comment, Location(column: 1, line: 8)),
            Token(Expression(content: "a step comment"), Location(column: 3, line: 8)),
            Token(EOF(), Location(column: 17, line: 8))
        ])
    }
    
    func testDataTable() {
        given(input: """
            Given this table:
                | title of column |
                | data 1          |
                | data 2          |
            """)
        whenLexing()
        thenTokens(are: [
            Token(PrimaryKeyword.given, Location(column: 1, line: 1)),
            Token(Expression(content: "this table:"), Location(column: 7, line: 1)),
            Token(SecondaryKeyword.pipe, Location(column: 5, line: 2)),
            Token(Expression(content: "title of column"), Location(column: 7, line: 2)),
            Token(SecondaryKeyword.pipe, Location(column: 23, line: 2)),
            
            Token(SecondaryKeyword.pipe, Location(column: 5, line: 3)),
            Token(Expression(content: "data 1"), Location(column: 7, line: 3)),
            Token(SecondaryKeyword.pipe, Location(column: 23, line: 3)),
            
            Token(SecondaryKeyword.pipe, Location(column: 5, line: 4)),
            Token(Expression(content: "data 2"), Location(column: 7, line: 4)),
            Token(SecondaryKeyword.pipe, Location(column: 23, line: 4)),
            
            Token(EOF(), Location(column: 24, line: 4))
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
        /*if tokens != expectedTokens {
            print("   EXPECTED".padded + "    ACTUAL".padded)
            for (index, token) in zip(expectedTokens, tokens).enumerated() {
                print("\(index): \(token.0.padded) \(token.1.padded)")
            }
        }*/
        
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
