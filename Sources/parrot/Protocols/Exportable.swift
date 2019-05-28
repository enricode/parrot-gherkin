//
//  Exportable.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/05/2019.
//

import Foundation

public protocol Exportable {
    func export() -> [String: Any]
}

extension Collection where Element: Exportable {
    
    func export() -> [[String: Any]] {
        return map { $0.export() }
    }
    
}
