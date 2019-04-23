import Foundation

struct Token: Equatable {
    let type: TokenType
    let value: String?
    let location: Location
    
    init(_ type: TokenType, value: String? = nil, _ location: Location) {
        self.type = type
        self.value = value
        self.location = location
    }
    
    var keyword: GherkinKeyword? {
        if case .keyword(let keyword) = type {
            return keyword
        }
        return nil
    }
    
    static func ==(lhs: Token, rhs: TokenType) -> Bool {
        return lhs.type == rhs
    }
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        return lhs.type == rhs.type && lhs.value == rhs.value && lhs.location == rhs.location
    }
}

extension Token {
    
    var isComment: Bool {
        if case .comment(_) = type {
            return true
        }
        return false
    }
    
    var isEOF: Bool {
        return type == .eof
    }
    
    var isExpression: Bool {
        return type == .expression
    }
    
    var isFeatureKeyword: Bool {
        if let keyword = keyword {
            return (keyword as? PrimaryKeyword) == .feature
        }
        return false
    }
    
    var isStepKeyword: Bool {
        if case .keyword(let keyword) = type {
            return keyword is StepKeyword
        }
        return false
    }
    
    var isRuleKeyword: Bool {
        if let keyword = keyword as? PrimaryKeyword {
            return keyword == .rule
        }
        return false
    }
    
    var isDocStringKeyword: Bool {
        return keyword is DocStringKeyword
    }
    
    var isScenarioKeyword: Bool {
        if case .keyword(let keyword) = type, let primaryKeyword = keyword as? PrimaryKeyword {
            return primaryKeyword.isOne(of: [.scenario, .scenarioOutline, .background])
        }
        return false
    }
    
    var isScenarioOutlineKeyword: Bool {
        if case .keyword(let keyword) = type, let primaryKeyword = keyword as? PrimaryKeyword {
            return primaryKeyword == .scenarioOutline
        }
        return false
    }
    
    var isPipeKeyword: Bool {
        if case .keyword(let keyword) = type, let secondaryKeyword = keyword as? SecondaryKeyword {
            return secondaryKeyword == .pipe
        }
        return false
    }
    
    var isPrimaryKeyword: Bool {
        if case .keyword(let keyword) = type {
            return keyword is PrimaryKeyword
        }
        return false
    }
    
    var isTagToken: Bool {
        if case .keyword(let keyword) = type, let secondaryKeyword = keyword as? SecondaryKeyword, case .tag(_) = secondaryKeyword {
            return true
        }
        return false
    }
    
    var isExamplesToken: Bool {
        if case .keyword(let keyword) = type, let primaryKeyword = keyword as? PrimaryKeyword {
            return primaryKeyword == .examples
        }
        return false
    }
    
    func isDocStringOf(type: DocStringKeyword.Keyword) -> Bool {
        guard let docStringKeyword = keyword as? DocStringKeyword else {
            return false
        }
        return docStringKeyword.keyword == type
    }
}

extension Collection where Element == Token {
    
    var value: String {
        guard !isEmpty else {
            return ""
        }
        return compactMap({ $0.value }).joined(separator: " ")
    }
    
    var valueExcludingFirst: String {
        guard count > 1 else {
            return ""
        }
        
        return dropFirst().value
    }
    
}
