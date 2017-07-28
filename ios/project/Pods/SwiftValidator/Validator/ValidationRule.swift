//
//  ValidationRule.swift
//  Pingo
//
//  Created by Jeff Potter on 11/11/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation
import UIKit

open class ValidationRule {
    open var textField:UITextField
    open var errorLabel:UILabel?
    open var rules:[Rule] = []
    
    public init(textField: UITextField, rules:[Rule], errorLabel:UILabel?){
        self.textField = textField
        self.errorLabel = errorLabel
        self.rules = rules
    }
    
    open func validateField() -> ValidationError? {
        return rules.filter{ !$0.validate(self.textField.text ?? "") }
                    .map{ rule -> ValidationError in return ValidationError(textField: self.textField, errorLabel:self.errorLabel, error: rule.errorMessage()) }.first
    }
}
