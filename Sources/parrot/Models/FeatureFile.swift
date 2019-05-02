import Foundation

struct CannotReadFeatureFile: Error {}

struct FeatureFile {
    let uri: URL
    
    func contentOfFeature() throws -> String {
        do {
            return try String(contentsOfFile: uri.absoluteString)
        } catch {
            throw CannotReadFeatureFile()
        }
    }
}
