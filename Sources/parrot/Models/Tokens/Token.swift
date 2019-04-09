import Foundation

struct Token {
    let type: TokenType
    let value: String?
    let location: Location
    
    init(_ type: TokenType, value: String? = nil, _ location: Location) {
        self.type = type
        self.value = value
        self.location = location
    }
    
    static func ==(lhs: Token, rhs: TokenType) -> Bool {
        return lhs.type == rhs
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
        if case .keyword(let keyword) = type {
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
        if case .keyword(let keyword) = type {
            return (keyword as? PrimaryKeyword) == .rule
        }
        return false
    }
    
    var isDocStringKeyword: Bool {
        if case .keyword(let keyword) = type {
            return keyword is DocStringKeyword
        }
        return false
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
    
    var isTagToken: Bool {
        return false
    }
    
    var isExamplesToken: Bool {
        return false
    }
    
    func isDocStringOf(type: DocStringKeyword.Keyword) -> Bool {
        return false
    }
}
