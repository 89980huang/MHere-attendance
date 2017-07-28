//
//  MaxLengthRule.swift
//  Validator
//
//  Created by Guilherme Berger on 4/6/15.
//

import Foundation

open class MaxLengthRule: Rule {
    
    fileprivate var DEFAULT_LENGTH: Int = 16
    fileprivate var message : String = "Must be at most 16 characters long"
    
    public init(){}
    
    public init(length: Int, message : String = "Must be at most %ld characters long"){
        self.DEFAULT_LENGTH = length
        self.message = NSString(format: message, self.DEFAULT_LENGTH) as String
    }
        
    open func validate(_ value: String) -> Bool {
        return value.characters.count <= DEFAULT_LENGTH
    }
    
    open func errorMessage() -> String {
        return message
    }
}
