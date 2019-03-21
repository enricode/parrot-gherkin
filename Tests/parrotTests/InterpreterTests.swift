import XCTest
@testable import parrot
/*
final class InterpreterTests: XCTestCase {
    
    var interpreter: CucumberInterpreter!
    var error: ParrotError!
    var feature: Feature!
    
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
    
    func testCompleteFeature() throws {
        let givenStep = "an initial condition named \"Desire\" for Scenario:, simple and clean"
        let whenStep = "an action with <A> and \"<B>\" exampleParameters"
        
        let feature: [Token] = [
            tagTokens(["tag1", "tag2"]),
            featureTokens(named: "Test Feature", description: "This feature is intended to be tested"),
            
            tagTokens(["tag3"]),
            scenarioTokens(named: "Test scenario", description: "Scenario is good"),
            givenStepTokens(content: givenStep),
            whenStepTokens(content: "an action"),
            dataTableTokens(rows: [["A1", "A2"], ["B1", "B2"]]),
            thenStepTokens(content: "outcome | is this"),
            
            tagTokens(["tag3", "tag4"]),
            scenarioOutlineTokens(title: "Test scenario Outline"),
            givenStepTokens(content: "an initial condition for Scenario Outline:"),
            whenStepTokens(content: whenStep),
            thenStepTokens(content: "outcome is this"),
            examplesTableTokens(title: "Example values", headers: ["A", "B"], rows: [["A1", "B1"], ["A2", "B2"]])
        ].flatMap { $0 }
        
        given(input: feature)
        whenInterpreting()
        thenFeature(is: try Feature(
            tags: [Tag(tag: "tag1"), Tag(tag: "tag2")],
            title: "Test Feature",
            description: "This feature is intended to be tested",
            scenarios: [
                Scenario(
                    tags: [Tag(tag: "tag3")],
                    title: "Test scenario",
                    description: "Scenario is good",
                    steps: [
                        Step(
                            keyword: .given,
                            text: givenStep,
                            parameters: [
                                Step.Parameter(
                                    kind: .parameter,
                                    value: "Desire",
                                    position: givenStep.index(givenStep.startIndex, offsetBy: 29)...givenStep.index(givenStep.startIndex, offsetBy: 35)
                                )
                            ],
                            dataTable: nil
                        ),
                        Step(
                            keyword: .when,
                            text: "an action",
                            parameters: [],
                            dataTable: DataTable(values: [["A1", "A2"], ["B1", "B2"]])
                        ),
                        Step(
                            keyword: .then,
                            text: "outcome | is this",
                            parameters: [],
                            dataTable: nil
                        )
                    ],
                    outline: .notOutline
                ),
                Scenario(
                    tags: [Tag(tag: "tag3"), Tag(tag: "tag4")],
                    title: "Test scenario Outline",
                    description: nil,
                    steps: [
                        Step(
                            keyword: .given,
                            text: "an initial condition for Scenario Outline:",
                            parameters: [],
                            dataTable: nil
                        ),
                        Step(
                            keyword: .when,
                            text: whenStep,
                            parameters: [],
                            dataTable: nil
                        ),
                        Step(
                            keyword: .then,
                            text: "outcome is this",
                            parameters: [],
                            dataTable: nil
                        )
                    ],
                    outline: .outline(examples: ExamplesTable(
                        title: "Example values",
                        columns: ["A", "B"],
                        dataTable: DataTable(values: [["A1", "B1"], ["A2", "B2"]])
                    ))
                )
            ])
        )
    }
    
    func tagTokens(_ tags: [String]) -> [Token] {
        let tokens = tags.map({ [Token.tag(value: $0), Token.whitespaces(count: 1)] })
        return tokens.joined() + [Token.newLine]
    }
    
    func featureTokens(named: String = "Feature name", description: String? = nil) -> [Token] {
        return [Token.scenarioKey(.feature), Token.word(value: named)]
            + (description != nil ? [Token.newLine, Token.word(value: description!)] : [])
            + [Token.newLine]
    }
    
    func scenarioTokens(named: String = "Scenario title", description: String? = nil) -> [Token] {
        let scenario = [
            Token.scenarioKey(.scenario),
            Token.word(value: named),
            Token.newLine
        ]
        
        let desc: [Token]
        if let description = description {
            desc = [Token.word(value: description), Token.newLine]
        } else {
            desc = []
        }
        
        return scenario + desc
    }
    
    func scenarioOutlineTokens(title: String = "Scenario outline title") -> [Token] {
        return [
            Token.scenarioKey(.outline),
            Token.word(value: title),
            Token.newLine
        ]
    }
    
    func givenStepTokens(content: String = "an actual condition") -> [Token] {
        return [
            Token.stepKeyword(.given),
            Token.whitespaces(count: 1),
            Token.word(value: content),
            Token.newLine
        ]
    }
    
    func whenStepTokens(content: String = "an action is made") -> [Token] {
        return [
            Token.stepKeyword(.when),
            Token.whitespaces(count: 1),
            Token.word(value: content),
            Token.newLine
        ]
    }
    
    func thenStepTokens(content: String = "the outcome is this") -> [Token] {
        return [
            Token.stepKeyword(.then),
            Token.whitespaces(count: 1),
            Token.word(value: content),
            Token.newLine
        ]
    }
    
    func examplesTableTokens(title: String, headers: [String], rows: [[String]]) -> [Token] {
        let headersToken = headers.flatMap { header in
            return [Token.pipe, Token.word(value: header)]
        }

        let tokens: [[Token]] = [
            [Token.scenarioKey(.examples), Token.word(value: title), Token.newLine],
            headersToken,
            [Token.pipe, Token.newLine],
            dataTableTokens(rows: rows)
        ]

        return tokens.flatMap { tokens -> [Token] in
            return tokens
        }
    }
    
    func dataTableTokens(rows: [[String]]) -> [Token] {
        return rows.flatMap { rowValues -> [Token] in
            let rowTokens = rowValues.flatMap { value in
                return [Token.pipe, Token.word(value: value)]
            }
            return rowTokens + [Token.pipe, Token.newLine]
        }
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
            feature = try interpreter.parse() as? Feature
        } catch {
            self.error = error as? ParrotError
        }
    }
    
    private func thenFeature(is feature: Feature) {
        XCTAssertEqual(self.feature, feature)
    }
    
    private func thenErrorCatched(is error: ParrotError) {
        XCTAssert(self.error.isSameError(as: error), "Error \(String(describing: self.error)) is not the same as \(error)")
    }
    
    static var allTests = [
        ("testIncompleteFeature", testIncompleteFeature)
    ]
}
*/
