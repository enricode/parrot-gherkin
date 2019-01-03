//
//  Interpreter.swift
//  parrot
//
//  Created by Enrico Franzelli on 30/12/18.
//

import Foundation

protocol Interpreter {
    var lexer: Lexer { get }
    func parse() throws -> AST
}
