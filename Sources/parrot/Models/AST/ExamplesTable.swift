import Foundation

enum ExamplesTableInitializationException: String, ParrotError {
    case emptyTitle
}

struct ExamplesTable: AST, Equatable {
    let title: String
    let dataTable: DataTable
    
    init(title: String, dataTable: DataTable) throws {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ExamplesTableInitializationException.emptyTitle
        }
        
        self.title = title
        self.dataTable = dataTable
    }
}
