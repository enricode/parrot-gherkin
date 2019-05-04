import Foundation

enum ScannerLineType: Equatable {
    case feature
    case background
    case examples
    case rule
    case scenario
    case step
    case language
    case docString
    case other
    case tag
    case tableRow
    case eof
    
    init<T: ScannerElementDescriptor>(type: T) {
        switch T.typeIdentifier {
        case BackgroundLineScannerElement.typeIdentifier: self = .background
        case FeatureLineScannerElement.typeIdentifier: self = .feature
        case ExamplesLineScannerElement.typeIdentifier: self = .examples
        case RuleLineScannerElement.typeIdentifier: self = .rule
        case ScenarioLineScannerElement.typeIdentifier: self = .scenario
        case StepLineScannerElement.typeIdentifier: self = .step
        case LanguageScannerElement.typeIdentifier: self = .language
        case DocStringSeparatorScannerElement.typeIdentifier: self = .docString
        case OtherScannerElement.typeIdentifier: self = .other
        case TagLineScannerElement.typeIdentifier: self = .tag
        case TableRowScannerElement.typeIdentifier: self = .tableRow
        default: self = .eof
        }
    }
}

extension ScannerElementDescriptor {
    
    func isOf(type: ScannerLineType) -> Bool {
        return ScannerLineType(type: self) == type
    }
    
    static func ==(lhs: Self, rhs: ScannerLineType) -> Bool {
        return lhs.isOf(type: rhs)
    }

    static func !=(lhs: Self, rhs: ScannerLineType) -> Bool {
        return !(lhs == rhs)
    }
    
}
