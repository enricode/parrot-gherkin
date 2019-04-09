import Foundation

struct DataTableValidator: Validator {
    
    func validate(object: DataTable) throws -> Bool {        
        guard object.rows.first != nil else {
            throw DataTableInitializationException.dataTableWithoutValues
        }
        
        return true
    }
    
}
