import Foundation

enum DataTableInitializationException: ParrotError {
    case dataTableWithoutValues
    case unmatchingCellsCount(row: Int)
}

public struct DataTable: AST, Equatable {
    
    enum Cell: AST, Equatable {
        case empty
        case value(String)
        
        var stringValue: String {
            switch self {
            case .empty: return ""
            case .value(let value): return value
            }
        }
        
        func export() -> [String : Any] {
            return ["value": stringValue]
        }
    }
    
    struct Row: AST, Equatable {
        let cells: [ASTNode<Cell>]
        
        func export() -> [String : Any] {
            return ["cells": cells.export()]
        }
    }
    
    let rows: [ASTNode<Row>]
    
    var header: ASTNode<Row> {
        return rows[0]
    }
    
    var body: ArraySlice<ASTNode<Row>> {
        guard rows.count > 1 else {
            return []
        }
        
        return rows[1...rows.count]
    }
    
    init(rows: [ASTNode<Row>]) throws {
        let cellsCount = rows.first?.element.cells.count
        
        try (0...(rows.count-1)).forEach { row in
            if rows[row].element.cells.count != cellsCount {
                throw DataTableInitializationException.unmatchingCellsCount(row: row)
            }
        }
        
        self.rows = rows
    }
    
    public func export() -> [String: Any] {
        return ["rows": rows.export()]
    }
    
}
