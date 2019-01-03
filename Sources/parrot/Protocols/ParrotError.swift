//
//  ParrotError.swift
//  parrot
//
//  Created by Enrico Franzelli on 02/01/19.
//

import Foundation

protocol ParrotError: Error {
    var hash: String { get }
    func isSameError(as error: ParrotError) -> Bool
}

extension ParrotError {
    var hash: String {
        return String(describing: self)
    }
}

extension ParrotError where Self: RawRepresentable, Self.RawValue == String {
    var hash: String {
        return rawValue
    }
}

extension ParrotError {
    func isSameError(as error: ParrotError) -> Bool {
        return error.hash == self.hash
    }
}
