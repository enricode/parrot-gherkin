import Foundation

protocol ScannerElement {}
protocol FirstLevelScannerElement: ScannerElement {}
struct FirstLevelScannerElemenDescriptor: FirstLevelScannerElement {}

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
    var isEOFAmmissible: Bool {
        return state != .scenarioTag
    }
    
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
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [LanguageScannerElement.self, TagLineScannerElement.self, FeatureLineScannerElement.self, EOFScannerElement.self])
            }
        case .featureTag:
            switch element {
            case is TagLineScannerElement: state = .featureTag
            case is FeatureLineScannerElement: state = .feature
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [TagLineScannerElement.self, FeatureLineScannerElement.self])
            }
        case .feature:
            switch element {
            case is OtherScannerElement: return
            case is TagLineScannerElement: state = .scenarioTag
            case is FirstLevelScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [OtherScannerElement.self, TagLineScannerElement.self, FirstLevelScannerElemenDescriptor.self, EOFScannerElement.self])
            }
        case .scenarioTag:
            switch element {
            case is TagLineScannerElement: return
            case is FirstLevelScannerElement: state = .scenario
            case is ExamplesLineScannerElement: state = .examples
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [ExamplesLineScannerElement.self, TagLineScannerElement.self, FirstLevelScannerElemenDescriptor.self])
            }
        case .scenario:
            switch element {
            case is OtherScannerElement, is FirstLevelScannerElement: return
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
            case is FirstLevelScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [StepLineScannerElement.self, TagLineScannerElement.self, DocStringSeparatorScannerElement.self, ExamplesLineScannerElement.self, TableRowScannerElement.self, FirstLevelScannerElemenDescriptor.self, EOFScannerElement.self])
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
                        throw InconsistentCellCount()
                    }
                }
                return
            case is StepLineScannerElement: state = .step
            case is FirstLevelScannerElement: state = .scenario
            case is TagLineScannerElement: state = .scenarioTag
            case is ExamplesLineScannerElement: state = .examples
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [TableRowScannerElement.self, StepLineScannerElement.self, FirstLevelScannerElemenDescriptor.self, TagLineScannerElement.self, ExamplesLineScannerElement.self, EOFScannerElement.self])
            }
        case .examples:
            switch element {
            case is OtherScannerElement: return
            case is TableRowScannerElement: state = .table(cellCount: (element as! TableRowScannerElement).items.count)
            case is TagLineScannerElement: state = .scenarioTag
            case is FirstLevelScannerElement: state = .scenario
            case is EOFScannerElement: return
            default: throw ScannerUnexpectedElement(unexpected: element, expected: [OtherScannerElement.self, TableRowScannerElement.self, TagLineScannerElement.self, FirstLevelScannerElemenDescriptor.self, EOFScannerElement.self])
            }
        }
    }
}
