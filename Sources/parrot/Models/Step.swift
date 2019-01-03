//
//  Step.swift
//  parrot
//
//  Created by Enrico Franzelli on 30/12/18.
//

import Foundation

struct Step {
    let text: String
    let parameters: [(value: String, position: Range<String.Index>)]
}
