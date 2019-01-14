//
//  Feature.swift
//  parrot
//
//  Created by Enrico Franzelli on 29/12/18.
//

import Foundation

enum FeatureInitializationException: String, ParrotError {
    case emptyTitle
    case emptyScenarios
    case emptyDescription
}

struct Feature: AST, Equatable {
    let tags: [Tag]
    let title: String
    let description: String?
    let scenarios: [Scenario]
    
    init(tags: [Tag], title: String, description: String?, scenarios: [Scenario]) throws {
        self.tags = tags
        
        self.title = title
        if title.isEmpty {
            throw FeatureInitializationException.emptyTitle
        }
        
        self.description = description
        if let desc = description, desc.isEmpty {
            throw FeatureInitializationException.emptyDescription
        }
        
        self.scenarios = scenarios
        if scenarios.isEmpty {
            throw FeatureInitializationException.emptyScenarios
        }
    }
}
