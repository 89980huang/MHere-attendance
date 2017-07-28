//
//  LengthRule.swift
//  Validator
//
//  Created by Jeff Potter on 3/6/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class MinLengthRule: Rule {
    
    fileprivate var DEFAULT_LENGTH: Int = 3
    fileprivate var message : String = "Must be at least 3 characters long"

    public init(){}
    
    public init(length: Int, message : String = "Must be at least %ld characters long"){
        self.DEFAULT_LENGTH = length
        self.message = NSString(format: message, self.DEFAULT_LENGTH) as String
    }
    
    open func validate(_ value: String) -> Bool {
        return value.characters.count >= DEFAULT_LENGTH
    }
    
    open func errorMessage() -> String {
        return message
    }
}
