import Foundation

protocol Scanner {
    typealias Line = ScannerElementDescriptor
    
    var lexer: Lexer { get }
    func parseLines() -> Result<[Int: Line], ParseError>
    func stringLines() -> Result<String, ParseError>
}

