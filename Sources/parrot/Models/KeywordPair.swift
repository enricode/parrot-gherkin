//
//  KeywordPair.swift
//  parrot
//
//  Created by Enrico Franzelli on 29/05/2019.
//

import Foundation

protocol Keyword {}

struct KeywordPair<T: Keyword & Equatable>: Equatable {
    let keyword: String
    let type: T
}
