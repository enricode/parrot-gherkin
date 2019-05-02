import Foundation

struct ScannerUnexpectedElement: Error {
    let unexpected: ScannerElement
    let expected: [ScannerElement.Type]
}

struct InconsistentCellCount: Error {}
