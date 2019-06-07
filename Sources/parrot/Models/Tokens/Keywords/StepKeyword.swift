import Foundation

enum StepKeyword: String, Keyword, GherkinKeyword, KeywordLocalizable, CaseIterable, Equatable {
    case given
    case when
    case then
    case and
    case but
}
