//
//  Character+Extensions.swift
//  parrot
//
//  Created by Enrico Franzelli on 28/12/18.
//

import Foundation

extension Character {
    var isSpace: Bool {
        //TODO: put more whitespace characters here
        return self == " "
    }
    
    var isNewLine: Bool {
        //TODO: windows return
        return self == "\n" || self == "\r"
    }
    
    var isTagChar: Bool {
        return self == "@"
    }
    
    var isColon: Bool {
        return self == ":"
    }
    
    var isPipe: Bool {
        return self == "|"
    }
    
    var isExampleParameterOpen: Bool {
        return self == "<"
    }
    
    var isExampleParameterClose: Bool {
        return self == ">"
    }
    
    var isParameterOpen: Bool {
        return self == "\""
    }
    
    var isntSpace: Bool {
        return !isSpace && !isNewLine
    }
}
