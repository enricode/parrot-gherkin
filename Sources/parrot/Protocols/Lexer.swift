//
//  Lexer.swift
//  parrot
//
//  Created by Enrico Franzelli on 30/12/18.
//

import Foundation

protocol Lexer {
    var text: String { get }
    
    func parse() throws -> [Token]
    func getNextToken() throws -> Token
}
