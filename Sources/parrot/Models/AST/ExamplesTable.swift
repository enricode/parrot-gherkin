import Foundation

enum ExamplesTableInitializationException: String, ParrotError {
    case emptyTitle
}

struct ExamplesTable: AST, Equatable {
    let title: String?
    let description: String?
    let tags: [ASTNode<Tag>]
    let dataTable: ASTNode<DataTable>?
    
    init(title: String?, description: String?, tags: [ASTNode<Tag>], dataTable: ASTNode<DataTable>?) {
        self.title = title
        self.description = description
        self.dataTable = dataTable
        self.tags = tags
    }
}
