//
//  LoginViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftValidator
import SwiftyJSON
import Alamofire
import DBAlertController

class LoginViewController: UIViewController,
    UITextFieldDelegate,
    ValidationDelegate {

    // TextFields
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!

    // Error Labels
    @IBOutlet weak var emailErrLabel: UILabel!
    @IBOutlet weak var passwordErrLabel: UILabel!

    @IBOutlet weak var stuButton: UIBarButtonItem!
    @IBOutlet weak var quickLoginButton: UIBarButtonItem!
    
    
    let validator = Validator()
    let userDefaults = UserDefaults.standard
    let currentUser = UserManager.sharedInstance
    let requester = RequestHelper()
    var userRole = ""
    var textFields:[UITextField] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        hideDebugButtons()
        
        registerNextFields()
        hideErrorLabels()
        registerValidators()
        registerValidatorMessageStyle()
        
        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideDebugButtons() {
        
        stuButton?.isEnabled      = false
        stuButton?.tintColor    = UIColor.clear
        quickLoginButton?.isEnabled      = false
        quickLoginButton?.tintColor    = UIColor.clear
    }
    
    /// Go to next field
    func registerNextFields() {
        
        self.loginEmailTextField.delegate = self
        self.loginPasswordTextField.delegate = self
        
        textFields = [loginEmailTextField, loginPasswordTextField]
        
    }
    
    // Next Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        var currentTextField = textFields[0]
        
        for (index, field) in textFields.enumerated() {
            
            if textField == field {
                if index < textFields.count-1 {
                    currentTextField = textFields[index+1]
                    currentTextField.becomeFirstResponder()
                }
                else { // last item
                    currentTextField.resignFirstResponder()
                    // do submit stuff
                    validator.validate(self)
                }
            }
        }
        
        return true
    }



    // End editing mode when touch out of Text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    /// Validator:
    func hideErrorLabels() {
        emailErrLabel.text = ""
        passwordErrLabel.text = ""
    }

    func registerValidators() {
        // register validators
        validator.registerField(loginEmailTextField,
            errorLabel: emailErrLabel,
            rules: [RequiredRule(),
                EmailRule(regex: "[A-Z0-9a-z._%+-]+@(students\\.)?itu\\.edu",
                    message: "Invalid ITU email")
            ])
        
        validator.registerField(loginPasswordTextField,
            errorLabel: passwordErrLabel,
            rules: [RequiredRule(), MinLengthRule(length: 7)])
    }

    func registerValidatorMessageStyle() {
        // change text field style on error
        validator.styleTransformers(success:{ (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            validationRule.textField.textColor = Colors.greenD1

            }, error:{ (validationError) -> Void in
                validationError.errorLabel?.isHidden = false
                validationError.errorLabel?.text = validationError.errorMessage
                validationError.textField.textColor = UIColor.red
        })
    }
    
    func checkUserRole(_ email:String) -> String {
        
        if email =~ "students.itu.edu" {
            return "Student"
        } else if email =~ "itu.edu" {
            return "Professor"
        } else {
            return ""
        }
    }
    
    func validationSuccessful() {
        
        // set user role flag
        userRole = checkUserRole(loginEmailTextField.text!)
        
        // submit the form
        submitLoginForm([
            "email" : loginEmailTextField.text!,
            "password": loginPasswordTextField.text!
        ])
    }

    func validationFailed(_ errors:[UITextField:ValidationError]) {
        print("Validation Failed")
    }
    /// End Validator

    @IBAction func loginSignInPressed(_ sender: AnyObject) {

        validator.validate(self)

    }

    func showDashboard() {

        // set user flag
        userDefaults.set(Foundation.Date(), forKey: UDKeys.isNewUser)
        userDefaults.setValue(Config.version, forKey: UDKeys.version)
        userDefaults.setValue(userRole, forKey: UDKeys.userRole)
        
        // show dashboard
        self.performSegue(withIdentifier: "loginSuccess", sender: self)

    }

    func submitLoginForm(_ credentials:[String: String]) {
        
        view.endEditing(true)
        
        requester.loginUser(.Login, credentials: credentials,
            failureCallback: { (response) -> Void in // Failure
                
                // no response body
                Utils.alert("Login failed", message: "Could not connect to the server. Please try again later.")
                
            },
            successCallback: { (response) -> Void in // Success
                
                let json = JSON(data: response.data!)
                let error = json["non_field_errors"]
                let token = json["token"]
                let courses = json["courses"]
                
                if error != nil {
                    
                    Utils.alert("Login failed", message: error[0].string!)
                    
                }
                
                if token != nil {
                    
                    // save email and token
                    UserManager.sharedInstance.info.email = credentials["email"]!
                    UserManager.sharedInstance.info.token = token.string!
                    self.userDefaults.set(credentials["email"]!, forKey: UDKeys.uname)
                    self.userDefaults.set(token.string!, forKey: UDKeys.token)
                    
                    // get user info ( f name, l name, courses )
                    self.getUser(credentials["email"]!, token: token.string!)
                }
                
                if courses != nil {
                    for courseKey in courses.arrayValue {
                        
                        self.requester.getCourse(courseKey.stringValue, token: token.stringValue, failureCallback: { (response) -> Void in
                                log.error("connection error, no course data fetched")
                            }, successCallback: { (response) -> Void in
                                
                                log.info("login courses \(courses)")
                                
                                let json = JSON(data: response.data!)
                                if let res = response.response {
                                    
                                    switch res.statusCode {
                                    case 200:
                                        
                                        let course = Course.JSONtoCourse(json)
                                        CourseManager.sharedInstance.studentCourseData.append(course)
                                        
                                    default:
                                        log.warning("Code \(res.statusCode) not handled")
                                        return
                                    }
                                }
                        })
                    }
                }
        })
    }

    @IBAction func loginAsStudent(_ sender: AnyObject) {
        let credentials = [
            "email":"yt3@students.itu.edu",
            "password":"password"
        ]
        
        Utils.alert("Quick login for testing", message: "Login as student:\n yt3@students.itu.edu", okAction: "OK", cancelAction: "Cancel", okCallback: { (action) -> Void in
            // Login as test1001
            self.userRole = "Student"
            self.submitLoginForm(credentials)
            }
        )
        
    }
    @IBAction func loginAsProfessor(_ sender: AnyObject) {
    
        Utils.alert("Quick login for testing", message: "Login as professor:\n aa@itu.edu", okAction: "OK", cancelAction: "Cancel", okCallback: { (action) -> Void in
                // Login as test1001
                self.userRole = "Professor"
                self.submitLoginForm(["email": "aa@itu.edu", "password": "password"])
            }
        )
    }
    
    func getUser(_ email: String, token: String) {
        
        var isStudent = false
        
        if email =~ "students.itu.edu" {
            
            isStudent = true
            
        } else if email =~ "itu.edu" {
            
            isStudent = false
            
        }
        
        requester.getUserData(( isStudent ? .Student : .Professor), token: token, email: email) { (response) -> Void in
            
            if let res = response.response {
                
                let json = JSON(data: response.data!)
                
                var message = json.description
                
                switch res.statusCode {
                case 404: // user not found
                    Utils.alert("Error", message: message)
                case 403:
                    Utils.alert("Error", message: message)
                case 200:
                    
                    message = json.description

                    let email = json["email"]
                    let firstName = json["first_name"]
                    let lastName = json["last_name"]
                    let courses = json["courses"]
                    let gender = json["gender"]
                    
                    if email != nil {
                        if !email.string!.isEmpty {
                            self.currentUser.info.email = email.string!
                        }
                    }

                    if firstName != nil {
                        if !firstName.string!.isEmpty {
                            self.currentUser.info.firstName = firstName.string!
                        }
                    }

                    if lastName != nil {
                        if !lastName.string!.isEmpty {
                            self.currentUser.info.lastName = lastName.string!
                        }
                    }
                    
                    self.userDefaults.set(email.string!, forKey: UDKeys.uname)
                    
                    if email.string! =~ "students.itu.edu" {
                        
                        UserManager.sharedInstance.info.role = "Student"
                        self.userDefaults.set("Student", forKey: UDKeys.userRole )
                        
                        if gender != nil {
                            UserManager.sharedInstance.info.gender = gender.int
                        }
                        
                        if courses != nil {
                            
                            // TODO: parse course data from JSON
                            
                            // let coursesData = [Course]()
                            
                            // CourseManager.sharedInstance.studentCourseData
                            
                        }
                        
                    } else if email.string! =~ "itu.edu" {
                        
                        UserManager.sharedInstance.info.role = "Professor"
                        self.userDefaults.set("Professor", forKey: UDKeys.userRole )
                        
                        
                        
                        if courses != nil {
                            
                            // TODO: parse course data from JSON
                            
                            // let coursesData = [Course]()
                            
                            // CourseManager.sharedInstance.courseData
                            
                        }
                        
                    }
                    
                    self.showDashboard()
                    
                    Utils.alert("User Data Recieved: \n", message: message, okAction: "OK")
                default:
                    log.error("Error: \(res.statusCode) not handled - getUser")
                }
            
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        
        let alertController = DBAlertController(title: "Select your role", message: "Are you a ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Student", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.userDefaults.set("Student", forKey: UDKeys.userRole )
            self.performSegue(withIdentifier: "selectStudentRegister", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Professor", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.userDefaults.set("Professor", forKey: UDKeys.userRole )
            self.performSegue(withIdentifier: "selectProfessorRegister", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.show()
        
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
