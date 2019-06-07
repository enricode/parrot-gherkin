import Foundation
import XCTest

struct TestFeature {
    let path: String
    
    var content: String {
        return content(of: path)
    }
    
    var tokens: String {
        return content(of: path + ".tokens")
    }
    
    var errors: String {
        return content(of: path + ".errors.ndjson")
    }
    
    var ast: String {
        return content(of: path + ".ast.ndjson")
    }
    
    var astFeature: [String: Any] {
        guard
            let dictionary = ast.dictionaryObject,
            let gherkinDocument = dictionary["gherkinDocument"] as? [String: Any]
        else {
            XCTFail("Cannot read AST file")
            return [:]
        }
        
        guard let feature = gherkinDocument["feature"] as? [String: Any] else {
            return [:]
        }
        
        return feature
    }
    
    var exportedErrors: [ExportableError] {
        let errorComponents = errors.components(separatedBy: "\n")
        
        return errorComponents.compactMap { component in
            guard !component.isEmpty else {
                return nil
            }
            
            guard let jsonObject = component.dictionaryObject else {
                XCTFail("Cannot convert error data from feature error file '\(path)'")
                return nil
            }
            
            guard let attachmentDict = jsonObject["attachment"] as? [String: Any] else {
                XCTFail("Error format 'attachment' key not found")
                return nil
            }
            
            guard
                let attachmentData = try? JSONSerialization.data(withJSONObject: attachmentDict, options: []),
                let error = try? JSONDecoder().decode(ExportableError.self, from: attachmentData)
            else {
                XCTFail("Cannot convert error")
                return nil
            }
            
            return error
        }
    }
    
    func content(of path: String) -> String {
        do {
            return try String(contentsOfFile: path)
        } catch {
            XCTFail("Cannot read feature")
            return ""
        }
    }
}

extension String {
    
    fileprivate var dictionaryObject: [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            return jsonObject
        } catch {
            return nil
        }
    }
    
}
