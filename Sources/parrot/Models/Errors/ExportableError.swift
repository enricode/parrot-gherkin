import Foundation

struct ExportableError: Error, Sourceable, Codable, Equatable {
    var data: String
    var source: Source
    
    var json: String {
        let encoder = JSONEncoder()
        
        let info = ["attachment": self]
        
        do {
            let data = try encoder.encode(info)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    static func ==(lhs: ExportableError, rhs: ExportableError) -> Bool {
        return lhs.source.location == rhs.source.location && lhs.data == rhs.data
    }
}
