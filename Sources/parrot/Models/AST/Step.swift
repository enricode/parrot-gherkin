import Foundation

enum StepInitializationException: String, ParrotError {
    case emptyStepText
    case parametersOutOfBounds
}

struct Step: AST, Equatable {
    let keyword: StepKeyword
    let text: String
    
    let docString: ASTNode<DocString>?
    let dataTable: ASTNode<DataTable>?
    
    init(keyword: StepKeyword, text: String, docString: ASTNode<DocString>?, dataTable: ASTNode<DataTable>?) throws {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            throw StepInitializationException.emptyStepText
        }
        
        self.keyword = keyword
        self.text = text

        self.docString = docString
        self.dataTable = dataTable
    }
}
