//
//  Required.swift
//  pyur-ios
//
//  Created by Jeff Potter on 12/22/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class RequiredRule: Rule {
    
    fileprivate var message : String 
    
    public init(message : String = "This field is required"){
        self.message = message
    }
    
    open func validate(_ value: String) -> Bool {
        return !value.isEmpty
    }
    
    open func errorMessage() -> String {
        return message
    }
}
