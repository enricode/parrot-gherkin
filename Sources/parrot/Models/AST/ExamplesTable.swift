import Foundation

enum ExamplesTableInitializationException: String, ParrotError {
    case emptyTitle
}

public struct ExamplesTable: AST, Equatable {
    let keyword: String
    let title: String?
    let description: String?
    let tags: [ASTNode<Tag>]
    let dataTable: ASTNode<DataTable>?
    
    init(keyword: String, title: String?, description: String?, tags: [ASTNode<Tag>], dataTable: ASTNode<DataTable>?) {
        self.keyword = keyword
        self.title = title
        self.description = description
        self.dataTable = dataTable
        self.tags = tags
    }
    
    public func export() -> [String : Any] {
        var examples: [String: Any] = ["keyword": keyword]
        
        if let dataTable = dataTable {
            examples["tableHeader"] = dataTable.exportHeader()
            
            if dataTable.element.rows.count > 1 {
                examples["tableBody"] = dataTable.exportBody()
            }
        }
        
        return examples
    }
}

extension ASTNode where ASTElement == DataTable {
    
    fileprivate func exportHeader() -> [String: Any] {
        return [
            "location": location.export(),
            "cells": element.header.export()
        ]
    }
    
    fileprivate func exportBody() -> [[String: Any]] {
        return element.body.export()
    }
    
}
