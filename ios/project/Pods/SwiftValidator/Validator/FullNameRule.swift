//
//  FullNameValidation.swift
//  Pingo
//
//  Created by Jeff Potter on 11/19/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation


open class FullNameRule : Rule {
    
    fileprivate var message : String
    
    public init(message : String = "Please provide a first & last name"){
        self.message = message
    }
        
    open func validate(_ value: String) -> Bool {
        let nameArray: [String] = value.characters.split { $0 == " " }.map { String($0) }
        return nameArray.count >= 2
    }
    
    open func errorMessage() -> String {
        return message
    }
}
