//
//  Scenario.swift
//  parrot
//
//  Created by Enrico Franzelli on 29/12/18.
//

import Foundation

enum ScenarioInitializationException: String, ParrotError {
    case emptyTitle
    case emptyDescription
    case emptySteps
    case noStepsFound
}

enum Outline: Equatable {
    case notOutline
    case outline(examples: ExamplesTable)
}

struct Scenario: AST, Equatable {
    let tags: [Tag]
    let title: String
    let description: String?
    let steps: [Step]
    let outline: Outline
    
    init(tags: [Tag], title: String, description: String?, steps: [Step], outline: Outline) throws {
        if title.isEmpty {
            throw ScenarioInitializationException.emptyTitle
        }
        
        if let desc = description, desc.isEmpty {
            throw ScenarioInitializationException.emptyDescription
        }
        
        if steps.isEmpty {
            throw ScenarioInitializationException.noStepsFound
        }
        
        self.tags = tags
        self.title = title
        self.description = description
        self.steps = steps
        self.outline = outline
    }
}
