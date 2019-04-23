import XCTest
@testable import parrot

final class LexerTests: XCTestCase {
    
    var lexer: CucumberLexer!
    var tokens: [Token] = []
    
    override func setUp() {
        lexer = nil
        tokens = []
    }
    
    func testIgnoresHeadingAndTrailingWhitespaces() {
        given(input: "     Hello   World   ")
        whenLexing()
        thenTokens(are: [
            Token(.expression, value: "Hello   World", Location(column: 6, line: 1)),
            Token(.eof, Location(column: 22, line: 1))
        ])
    }
    
    func testNewLines() {
        given(input: "\n\nFeature: A\n  Given \n  ")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.feature), value: "Feature:", Location(column: 1, line: 3)),
            Token(.expression, value: "A", Location(column: 10, line: 3)),
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 3, line: 4)),
            Token(.eof, Location(column: 3, line: 5))
        ])
    }
    
    func testSplitKeywordsWithoutWhitespaces() {
        given(input: "Feature:Hello")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.feature), value: "Feature:", Location(column: 1, line: 1)),
            Token(.expression, value: "Hello", Location(column: 9, line: 1)),
            Token(.eof, Location(column: 14, line: 1))
        ])
    }
    
    func testAdvanceWithFinalColon() {
        given(input: "Feature:")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.feature), value: "Feature:", Location(column: 1, line: 1)),
            Token(.eof, Location(column: 9, line: 1))
        ])
    }
    
    func testDocString() {
        given(input: """
            Given something with doc string
              \"""type
              Given first line indented like this
                it should preserve two spaces
                 and now three
             nothing if negative offset

              same when indented... the same
              \"""
            And something else
            """)
        whenLexing()
        thenTokens(are: [
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 1, line: 1)),
            Token(.expression, value: "something with doc string", Location(column: 7, line: 1)),
            Token(.keyword(DocStringKeyword(mark: "type", keyword: .doubleQuotes)), value: "\"\"\"type", Location(column: 3, line: 2)),
            Token(.expression, value: "Given first line indented like this", Location(column: 1, line: 3)),
            Token(.expression, value: "  it should preserve two spaces", Location(column: 1, line: 4)),
            Token(.expression, value: "   and now three", Location(column: 1, line: 5)),
            Token(.expression, value: "nothing if negative offset", Location(column: 1, line: 6)),
            Token(.expression, Location(column: 1, line: 7)),
            Token(.expression, value: "same when indented... the same", Location(column: 1, line: 8)),
            Token(.keyword(DocStringKeyword(mark: nil, keyword: .doubleQuotes)), value: "\"\"\"", Location(column: 3, line: 9)),
            Token(.keyword(StepKeyword.and), value: "And ", Location(column: 1, line: 10)),
            Token(.expression, value: "something else", Location(column: 5, line: 10)),
            Token(.eof, Location(column: 19, line: 10))
        ])
    }
    
    func testDocStringWithTrickySeparators() {
        given(input: """
            Given something with doc string
              \"""type
              ```
              hello
              \"""
            And hello
            """)
        whenLexing()
        thenTokens(are: [
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 1, line: 1)),
            Token(.expression, value: "something with doc string", Location(column: 7, line: 1)),
            Token(.keyword(DocStringKeyword(mark: "type", keyword: .doubleQuotes)), value: "\"\"\"type", Location(column: 3, line: 2)),
            Token(.expression, value: "```", Location(column: 1, line: 3)),
            Token(.expression, value: "hello", Location(column: 1, line: 4)),
            Token(.keyword(DocStringKeyword(mark: nil, keyword: .doubleQuotes)), value: "\"\"\"", Location(column: 3, line: 5)),
            Token(.keyword(StepKeyword.and), value: "And ", Location(column: 1, line: 6)),
            Token(.expression, value: "hello", Location(column: 5, line: 6)),
            Token(.eof, Location(column: 10, line: 6))
        ])
    }
    
    func testTags() {
        given(input: "@tag1 @tag2\nFeature: Hello")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(SecondaryKeyword.tag(name: "tag1")), value: "@tag1", Location(column: 1, line: 1)),
            Token(.keyword(SecondaryKeyword.tag(name: "tag2")), value: "@tag2", Location(column: 7, line: 1)),
            Token(.keyword(PrimaryKeyword.feature), value: "Feature:", Location(column: 1, line: 2)),
            Token(.expression, value: "Hello", Location(column: 10, line: 2)),
            Token(.eof, Location(column: 15, line: 2))
        ])
    }
    
    func testGivenWhenThen() {
        given(input: "Given hello\nWhen action\nThen happiness")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 1, line: 1)),
            Token(.expression, value: "hello", Location(column: 7, line: 1)),
            Token(.keyword(StepKeyword.when), value: "When ", Location(column: 1, line: 2)),
            Token(.expression, value: "action", Location(column: 6, line: 2)),
            Token(.keyword(StepKeyword.then), value: "Then ", Location(column: 1, line: 3)),
            Token(.expression, value: "happiness", Location(column: 6, line: 3)),
            Token(.eof, Location(column: 15, line: 3))
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
            Token(.keyword(PrimaryKeyword.scenarioOutline), value: "Scenario Outline:", Location(column: 1, line: 1)),
            Token(.expression, value: "Title of scenario", Location(column: 19, line: 1)),
            Token(.expression, value: "Description of scenario", Location(column: 19, line: 2)),
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 5, line: 3)),
            Token(.expression, value: "initial condition", Location(column: 11, line: 3)),
            Token(.eof, Location(column: 28, line: 3))
        ])
    }

    func testScenarioOutline() {
        given(input: "Scenario Outline:")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.scenarioOutline), value: "Scenario Outline:", Location(column: 1, line: 1)),
            Token(.eof, Location(column: 18, line: 1))
        ])
    }

    func testScenarioTemplate() {
        given(input: "Scenario Template:")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.scenarioOutline), value: "Scenario Template:", Location(column: 1, line: 1)),
            Token(.eof, Location(column: 19, line: 1))
        ])
    }

    func testExample() {
        given(input: "Example:")
        whenLexing()
        thenTokens(are: [
            Token(.keyword(PrimaryKeyword.scenario), value: "Example:", Location(column: 1, line: 1)),
            Token(.eof, Location(column: 9, line: 1))
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
            Token(.comment("this is a comment"), value: "# this is a comment", Location(column: 1, line: 1)),
            Token(.keyword(PrimaryKeyword.feature), value: "Feature:", Location(column: 1, line: 3)),
            Token(.expression, value: "A", Location(column: 10, line: 3)),
            Token(.comment("another comment"), value: "#another comment", Location(column: 1, line: 5)),
            Token(.keyword(PrimaryKeyword.scenario), value: "Scenario:", Location(column: 1, line: 6)),
            Token(.expression, value: "Hello", Location(column: 11, line: 6)),
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 5, line: 7)),
            Token(.expression, value: "this", Location(column: 11, line: 7)),
            Token(.comment("a step comment"), value: "# a step comment", Location(column: 1, line: 8)),
            Token(.eof, Location(column: 17, line: 8))
        ])
    }
    
    func testLanguage() {
        given(input: """
            # language: no
            Egenskap: Gjett et ord

                Eksempel: Ordmaker starter et spill
                    Når Ordmaker starter et spill
                    Så må Ordmaker vente på at Gjetter blir med
            """)
        whenLexing()
        thenTokens(are: [
            Token(.language("no"), value: "# language: no", Location(column: 1, line: 1)),
            Token(.keyword(PrimaryKeyword.feature), value: "Egenskap:", Location(column: 1, line: 2)),
            Token(.expression, value: "Gjett et ord", Location(column: 11, line: 2)),
            
            Token(.keyword(PrimaryKeyword.scenario), value: "Eksempel:", Location(column: 5, line: 4)),
            Token(.expression, value: "Ordmaker starter et spill", Location(column: 15, line: 4)),
            
            Token(.keyword(StepKeyword.when), value: "Når ", Location(column: 9, line: 5)),
            Token(.expression, value: "Ordmaker starter et spill", Location(column: 13, line: 5)),
            
            Token(.keyword(StepKeyword.then), value: "Så ", Location(column: 9, line: 6)),
            Token(.expression, value: "må Ordmaker vente på at Gjetter blir med", Location(column: 12, line: 6)),
            
            Token(.eof, Location(column: 52, line: 6))
        ])
    }

    func testDataTable() {
        given(input: """
            Given this table:
                | title of column | second column |
                | data 1          |data 3         |
                | ||
                | data 4|
            """)
        whenLexing()
        thenTokens(are: [
            Token(.keyword(StepKeyword.given), value: "Given ", Location(column: 1, line: 1)),
            Token(.expression, value: "this table:", Location(column: 7, line: 1)),
            
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 5, line: 2)),
            Token(.expression, value: "title of column", Location(column: 7, line: 2)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 23, line: 2)),
            Token(.expression, value: "second column", Location(column: 25, line: 2)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 39, line: 2)),
            
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 5, line: 3)),
            Token(.expression, value: "data 1", Location(column: 7, line: 3)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 23, line: 3)),
            Token(.expression, value: "data 3", Location(column: 24, line: 3)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 39, line: 3)),
            
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 5, line: 4)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 7, line: 4)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 8, line: 4)),
            
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 5, line: 5)),
            Token(.expression, value: "data 4", Location(column: 7, line: 5)),
            Token(.keyword(SecondaryKeyword.pipe), value: "|", Location(column: 13, line: 5)),
            
            Token(.eof, Location(column: 14, line: 5))
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
        if let differentTokens = tokens.differs(from: expectedTokens) {
            print("Different token encountered:")
            print(differentTokens.0)
            print(differentTokens.1)
            print("")
            
            for (index, token) in zip(expectedTokens, tokens).enumerated() {
                print("\(String(format: "%03d", index + 1)) EXPECTED: \(token.0)")
                print("    ACTUAL:   \(token.1)")
                print("")
            }
            
            XCTFail("Tokens are different \(expectedTokens) \n \(tokens)")
        }
        
        XCTAssert(true)
    }
    
    static var allTests = [
        ("testIgnoresHeadingAndTrailingWhitespaces", testIgnoresHeadingAndTrailingWhitespaces),
        ("testNewLines", testNewLines),
        ("testSplitKeywordsWithoutWhitespaces", testSplitKeywordsWithoutWhitespaces),
        ("testAdvanceWithFinalColon", testAdvanceWithFinalColon),
        ("testDocString", testDocString),
        ("testTags", testTags),
        ("testGivenWhenThen", testGivenWhenThen),
        ("testTitleAndDescription", testTitleAndDescription),
        ("testScenarioOutline", testScenarioOutline),
        ("testScenarioTemplate", testScenarioTemplate),
        ("testExample", testExample),
        ("testComments", testComments),
        ("testLanguage", testLanguage),
        ("testDataTable", testDataTable)
    ]
}

extension Collection where Element == Token {
    
    func differs(from tokens: [Element]) -> (Element, Element)? {
        let notEqual = zip(self, tokens).first { tokenPair in
            let (tk1, tk2) = tokenPair
            
            guard tk1.location == tk2.location else {
                return true
            }
            
            return String(describing: tk1) != String(describing: tk2)
        }
        
        return notEqual
    }
    
}
