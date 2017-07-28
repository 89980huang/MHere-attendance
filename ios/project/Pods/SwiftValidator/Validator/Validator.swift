//
//  Validator.swift
//  Pingo
//
//  Created by Jeff Potter on 11/10/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol ValidationDelegate {
    func validationSuccessful()
    func validationFailed(_ errors: [UITextField:ValidationError])
}

open class Validator {
    // dictionary to handle complex view hierarchies like dynamic tableview cells
    open var errors = [UITextField:ValidationError]()
    open var validations = [UITextField:ValidationRule]()
    fileprivate var successStyleTransform:((_ validationRule:ValidationRule)->Void)?
    fileprivate var errorStyleTransform:((_ validationError:ValidationError)->Void)?
    
    public init(){}
    
    // MARK: Private functions
    
    fileprivate func validateAllFields() {
        
        errors = [:]
        
        for (textField, rule) in validations {
            if let error = rule.validateField() {
                errors[textField] = error
                
                // let the user transform the field if they want
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
            } else {
                // No error
                // let the user transform the field if they want
                if let transform = self.successStyleTransform {
                    transform(rule)
                }
            }
        }
    }
    
    // MARK: Using Keys
    
    open func styleTransformers(success:((_ validationRule:ValidationRule)->Void)?, error:((_ validationError:ValidationError)->Void)?) {
        self.successStyleTransform = success
        self.errorStyleTransform = error
    }
    
    open func registerField(_ textField:UITextField, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules: rules, errorLabel: nil)
    }
    
    open func registerField(_ textField:UITextField, errorLabel:UILabel, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules:rules, errorLabel:errorLabel)
    }
    
    open func unregisterField(_ textField:UITextField) {
        validations.removeValue(forKey: textField)
        errors.removeValue(forKey: textField)
    }
    
    open func validate(_ delegate:ValidationDelegate) {
        
        self.validateAllFields()
        
        if errors.isEmpty {
            delegate.validationSuccessful()
        } else {
            delegate.validationFailed(errors)
        }
    }
    
    open func validate(_ callback:(_ errors:[UITextField:ValidationError])->Void) -> Void {
        
        self.validateAllFields()
        
        callback(errors)
    }
}
