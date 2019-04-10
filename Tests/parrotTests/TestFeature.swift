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
    
    func content(of path: String) -> String {
        do {
            return try String(contentsOfFile: path)
        } catch {
            XCTFail("Cannot read feature")
            return ""
        }
    }
}

