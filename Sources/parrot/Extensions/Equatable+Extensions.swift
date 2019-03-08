import Foundation

extension Equatable {
    
    func isOne(of these: [Self]) -> Bool {
        return these.first(where: { $0 == self }) != nil
    }
    
    func isNotOne(of these: [Self]) -> Bool {
        return these.first(where: { $0 == self }) == nil
    }
    
}
