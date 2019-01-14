//
//  Step.swift
//  parrot
//
//  Created by Enrico Franzelli on 30/12/18.
//

import Foundation

enum StepInitializationException: String, ParrotError {
    case emptyStepText
    case parametersOutOfBounds
}

struct Step: AST, Equatable {
    
    enum ParameterKind: Equatable {
        case parameter
        case example
    }
    
    enum Keyword: Equatable {
        case given
        case when
        case then
        case but
        case and
    }
    
    struct Parameter: Equatable {
        let kind: ParameterKind
        let value: String
        let position: ClosedRange<String.Index>
    }
    
    let keyword: Keyword
    let text: String
    let parameters: [Parameter]
    let dataTable: DataTable?
    
    init(keyword: Keyword, text: String, parameters: [Parameter], dataTable: DataTable?) throws {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            throw StepInitializationException.emptyStepText
        }
        
        try parameters.forEach { param in
            if text.startIndex > param.position.lowerBound || text.endIndex < param.position.upperBound {
                throw StepInitializationException.parametersOutOfBounds
            }
        }
        
        self.keyword = keyword
        self.text = text
        self.parameters = parameters
        self.dataTable = dataTable
    }
}
