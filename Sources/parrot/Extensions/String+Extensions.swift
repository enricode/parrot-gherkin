//
//  String+Extensions.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

extension String {
    var endsWithColon: Bool {
        return last == ":"
    }
    
    var isDocString: Bool {
        return self == "\"\"\""
    }
}
