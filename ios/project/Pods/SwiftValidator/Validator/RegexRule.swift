//
//  RegexRule.swift
//  Validator
//
//  Created by Jeff Potter on 4/3/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class RegexRule : Rule {
    
    fileprivate var REGEX: String = "^(?=.*?[A-Z]).{8,}$"
    fileprivate var message : String
    
    public init(regex: String, message: String = "Invalid Regular Expression"){
        self.REGEX = regex
        self.message = message
    }
    
    open func validate(_ value: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", self.REGEX)
        return test.evaluate(with: value)
    }
    
    open func errorMessage() -> String {
        return message
    }
}
