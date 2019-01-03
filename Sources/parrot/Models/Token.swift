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
    
    var representation: String {
        switch self {
        case .colon: return ":"
        case .exampleParameter(let value): return "<\(value)>"
        case .newLine: return "\n"
        case .parameter(let value): return "\"\(value)\""
        case .pipe: return "|"
        case .scenarioKey(let key):
            switch key {
            case .outline: return "Scenario Outline:"
            case .template: return "Scenario Template:"
            default: return key.rawValue
            }
        case .stepKeyword(let key): return key.rawValue
        case .tag(let value): return "@" + value
        case .whitespaces(let count): return String(repeatElement(" ", count: count))
        case .word(let value): return value
        case .EOF: return ""
        }
    }
}
