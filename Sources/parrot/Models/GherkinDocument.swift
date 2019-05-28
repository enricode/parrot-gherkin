//
//  GherkinDocument.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/05/2019.
//

import Foundation

struct GherkinDocument: Sourceable {
    let source: Source
    let feature: Feature
}
