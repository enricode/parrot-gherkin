import Foundation

enum StepInitializationException: String, ParrotError {
    case emptyStepText
    case parametersOutOfBounds
}

struct Step: AST, Equatable {
    let keyword: StepKeyword
    let text: String
    let dataTable: DataTable?
    
    init(keyword: StepKeyword, text: String, dataTable: DataTable?) throws {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            throw StepInitializationException.emptyStepText
        }
        
        self.keyword = keyword
        self.text = text
        self.dataTable = dataTable
    }
}
