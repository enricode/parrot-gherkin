import Foundation

enum SecondaryKeyword: GherkinKeyword, Equatable {
    case pipe
    case tag(name: String)
}
