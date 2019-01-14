//
//  HelperExtensions.swift
//  parrot
//
//  Created by Enrico Franzelli on 05/01/19.
//

import Foundation

extension Token {
    var padded: String {
        return String(describing: self).padded
    }
}

extension String {
    var padded: String {
        return self.padding(toLength: 35, withPad: " ", startingAt: 0)
    }
}
