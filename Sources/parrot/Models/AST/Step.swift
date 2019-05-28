import Foundation

public enum StepInitializationException: String, ParrotError {
    case emptyStepText
    case parametersOutOfBounds
}

public struct Step: AST, Equatable {
    
    struct Keyword: Equatable {
        let keyword: String
        let type: StepKeyword
    }
    
    let keyword: Keyword
    let text: String
    
    let docString: ASTNode<DocString>?
    let dataTable: ASTNode<DataTable>?
    
    init(keyword: Keyword, text: String, docString: ASTNode<DocString>?, dataTable: ASTNode<DataTable>?) throws {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            throw StepInitializationException.emptyStepText
        }
        
        self.keyword = keyword
        self.text = text

        self.docString = docString
        self.dataTable = dataTable
    }
    
    public func export() -> [String : Any] {
        var step: [String: Any] = [
            "keyword": keyword.keyword,
            "text": text
        ]
        
        if let dataTable = dataTable {
            step["dataTable"] = dataTable.export()
        }
        
        if let docString = docString {
            step["docString"] = docString.export()
        }
        
        return step
    }
}
