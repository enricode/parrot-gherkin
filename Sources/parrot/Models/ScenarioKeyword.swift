//
//  ScenarioKeyword.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

enum ScenarioKey: String, Keyword {
    case scenario = "Scenario:"
    case example = "Example:"
    case examples = "Examples:"
    case feature = "Feature:"
    case outline = "Outline:"
    case template = "Template:"
    case background = "Background:"
    
    var isScenarioKey: Bool {
        return self == .scenario || self == .example
    }
    
    var isScenarioOutlineKey: Bool {
        return self == .outline || self == .template
    }
}
