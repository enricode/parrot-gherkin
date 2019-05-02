import Foundation

protocol Scanner {
    typealias Line = ScannerElementDescriptor
    
    var lexer: Lexer { get }
    func parseLines() -> Result<[Int: Line], Error>
    func stringLines() -> Result<String, Error>
}

