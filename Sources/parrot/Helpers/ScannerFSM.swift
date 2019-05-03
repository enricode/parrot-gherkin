import Foundation

protocol ScannerElement: Locatable {
    static var typeIdentifier: String { get }
    
    var tokens: [Token] { get }
    var prettyPrint: String { get }
}

class ScannerFSM {

    enum State: Equatable {
        case beforeFeature
        case featureTag
        case feature
        case scenario
        case scenarioTag
        case step
        case table(cellCount: Int)
        case docString
        case examples
    }
    
    var state: State
    
    init() {
        state = .beforeFeature
    }
    
    func changeState(element: ScannerElement) throws {
        guard !(element is CommentScannerElement) else {
            return
        }
        guard !(element is EmptyScannerElement) else {
            return
        }
        
        switch state {
        case .beforeFeature:
            switch element {
            case is LanguageScannerElement: return
            case is TagLineScannerElement: state = .featureTag
            case is FeatureLineScannerElement: state = .feature
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [EOFScannerElement.self, LanguageScannerElement.self, TagLineScannerElement.self, FeatureLineScannerElement.self, CommentScannerElement.self, EmptyScannerElement.self])
            }
        case .featureTag:
            switch element {
            case is TagLineScannerElement: state = .featureTag
            case is FeatureLineScannerElement: state = .feature
            case is EOFScannerElement: throw UnexpectedEndOfFile(location: element.location, expected: [TagLineScannerElement.self, FeatureLineScannerElement.self])
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [TagLineScannerElement.self, FeatureLineScannerElement.self])
            }
        case .feature:
            switch element {
            case is OtherScannerElement: return
            case is TagLineScannerElement: state = .scenarioTag
            case is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [OtherScannerElement.self, TagLineScannerElement.self, BackgroundLineScannerElement.self, RuleLineScannerElement.self, ScenarioLineScannerElement.self, EOFScannerElement.self])
            }
        case .scenarioTag:
            switch element {
            case is TagLineScannerElement: return
            case is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: state = .scenario
            case is ExamplesLineScannerElement: state = .examples
            case is EOFScannerElement: throw UnexpectedEndOfFile(location: element.location, expected: [TagLineScannerElement.self, ScenarioLineScannerElement.self, CommentScannerElement.self, EmptyScannerElement.self])
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [ExamplesLineScannerElement.self, TagLineScannerElement.self, BackgroundLineScannerElement.self, RuleLineScannerElement.self, ScenarioLineScannerElement.self])
            }
        case .scenario:
            switch element {
            case is OtherScannerElement, is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: return
            case is StepLineScannerElement: state = .step
            case is ExamplesLineScannerElement: state = .examples
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [OtherScannerElement.self, StepLineScannerElement.self, ExamplesLineScannerElement.self, EOFScannerElement.self])
            }
        case .step:
            switch element {
            case is StepLineScannerElement: return
            case is TagLineScannerElement: state = .scenarioTag
            case is DocStringSeparatorScannerElement: state = .docString
            case is ExamplesLineScannerElement: state = .examples
            case is TableRowScannerElement: state = .table(cellCount: (element as! TableRowScannerElement).items.count)
            case is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [EOFScannerElement.self, TableRowScannerElement.self, DocStringSeparatorScannerElement.self, StepLineScannerElement.self, TagLineScannerElement.self, ExamplesLineScannerElement.self, ScenarioLineScannerElement.self, RuleLineScannerElement.self, CommentScannerElement.self, EmptyScannerElement.self])
            }
        case .docString:
            switch element {
            case is DocStringSeparatorScannerElement: state = .step
            case is OtherScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [DocStringSeparatorScannerElement.self, OtherScannerElement.self])

            }
        case .table:
            switch element {
            case is TableRowScannerElement:
                if case .table(let cells) = state {
                    let cellCountCurrentRow = (element as! TableRowScannerElement).items.count
                    if cells != cellCountCurrentRow {
                        throw InconsistentCellCount(location: element.location)
                    }
                }
                return
            case is StepLineScannerElement: state = .step
            case is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: state = .scenario
            case is TagLineScannerElement: state = .scenarioTag
            case is ExamplesLineScannerElement: state = .examples
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [TableRowScannerElement.self, StepLineScannerElement.self, BackgroundLineScannerElement.self, RuleLineScannerElement.self, ScenarioLineScannerElement.self, TagLineScannerElement.self, ExamplesLineScannerElement.self, EOFScannerElement.self])
            }
        case .examples:
            switch element {
            case is OtherScannerElement: return
            case is TableRowScannerElement: state = .table(cellCount: (element as! TableRowScannerElement).items.count)
            case is TagLineScannerElement: state = .scenarioTag
            case is BackgroundLineScannerElement, is RuleLineScannerElement, is ScenarioLineScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [OtherScannerElement.self, TableRowScannerElement.self, TagLineScannerElement.self, BackgroundLineScannerElement.self, RuleLineScannerElement.self, ScenarioLineScannerElement.self, EOFScannerElement.self])
            }
        }
    }
}
