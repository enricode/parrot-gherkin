import Foundation

enum ExamplesTableInitializationException: String, ParrotError {
    case emptyTitle
}

struct ExamplesTable: AST, Equatable {
    let title: String?
    let tags: [ASTNode<Tag>]
    let dataTable: ASTNode<DataTable>
    
    init(title: String?, tags: [ASTNode<Tag>], dataTable: ASTNode<DataTable>) throws {
        if let title = title, title.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ExamplesTableInitializationException.emptyTitle
        }
        
        self.title = title
        self.dataTable = dataTable
        self.tags = tags
    }
}
