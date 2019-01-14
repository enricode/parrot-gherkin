//
//  ExamplesTable.swift
//  parrot
//
//  Created by Enrico Franzelli on 02/01/19.
//

import Foundation

enum ExamplesTableInitializationException: String, ParrotError {
    case emptyTitle
    case emptyTableHeaders
    case unmatchedValuesCountWithColumns
}

struct ExamplesTable: Equatable {
    let title: String
    let columns: [String]
    let dataTable: DataTable
    
    init(title: String, columns: [String], dataTable: DataTable) throws {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ExamplesTableInitializationException.emptyTitle
        }
        
        if columns.isEmpty {
            throw ExamplesTableInitializationException.emptyTableHeaders
        }
        
        if columns.count != dataTable.values.first?.count {
            throw ExamplesTableInitializationException.unmatchedValuesCountWithColumns
        }
        
        self.title = title
        self.columns = columns
        self.dataTable = dataTable
    }
}
