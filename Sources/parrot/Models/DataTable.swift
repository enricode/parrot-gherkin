//
//  DataTable.swift
//  parrot
//
//  Created by Enrico Franzelli on 29/12/18.
//

import Foundation

enum DataTableInitializationException: String, ParrotError {
    case dataTableWithoutValues
}

struct DataTable: AST, Equatable {
    let values: [[String]]
    
    init(values: [[String]]) throws {
        guard let firstRow = values.first else {
            throw DataTableInitializationException.dataTableWithoutValues
        }
        
        let numberOfValuesPerRow = firstRow.count
        let numberOfRows = values.count
        
        guard numberOfRows >= 2 else {
            self.values = values
            return
        }
            
        try (1...(numberOfRows-1)).forEach { row in
            if values[row].count != numberOfValuesPerRow {
                throw DataTableInitializationException.dataTableWithoutValues
            }
        }
        
        self.values = values
    }
}
