//
//  Token.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

enum Token: Equatable {
    case colon
    case exampleParameter(value: String)
    case newLine
    case parameter(value: String)
    case pipe
    case scenarioKey(ScenarioKey)
    case stepKeyword(StepKeyword)
    case tag(value: String)
    case whitespaces(count: Int)
    case word(value: String)
    
    case EOF
}
