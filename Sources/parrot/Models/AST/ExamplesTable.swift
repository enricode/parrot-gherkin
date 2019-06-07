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
        
        if !tags.isEmpty {
            examples["tags"] = tags.export()
        }
        
        return examples
    }
}

extension ASTNode where ASTElement == DataTable {
    
    fileprivate func exportHeader() -> [String: Any] {
        var header = element.header.export()
        header["location"] = location.export()
        
        return header
    }
    
    fileprivate func exportBody() -> [[String: Any]] {
        return element.body.export()
    }
    
}
