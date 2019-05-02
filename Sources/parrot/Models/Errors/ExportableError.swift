import Foundation

protocol ExportableError: Error {
    var source: Source { get }
    var data: String { get }
}
