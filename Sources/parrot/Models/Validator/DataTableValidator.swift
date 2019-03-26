import Foundation

struct DataTableValidator: Validator {
    
    let mode: CucumberInterpreter.Mode
    
    func validate(object: DataTable) throws -> Bool {
        guard mode != .permissive else {
            return true
        }
        
        guard object.rows.first != nil else {
            throw DataTableInitializationException.dataTableWithoutValues
        }
        
        return true
    }
    
}
