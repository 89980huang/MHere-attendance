//
//  RegisterUserTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/25/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftValidator
import SwiftyJSON

class RegisterUserTableViewController: UITableViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITextFieldDelegate,
    ValidationDelegate {
    
    /// Input fields
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var studentGenderSegment: UISegmentedControl!
    @IBOutlet weak var studentIDTextField: UITextField!
    
    /// Error labels
    @IBOutlet weak var userFNameErrLabel: UILabel!
    @IBOutlet weak var userLNameErrLabel: UILabel!
    @IBOutlet weak var userEmailErrLabel: UILabel!
    @IBOutlet weak var userPasswordErrLabel: UILabel!
    @IBOutlet weak var studIDErrLabel: UILabel!
    
    let validator = Validator()
    let requester = RequestHelper()
    let userDefaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    
    var textFields:[UITextField] = []
    var userToRegister = UserManager.sharedInstance.toRegister
    fileprivate enum Genders: Int {
        case male = 0, female
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        userToRegister.role = userDefaults.string(forKey: UDKeys.userRole)!
        
        hideErrorLabels()
        registerValidators()
        registerValidatorMessageStyle()
        
        registerNextFields(isStudent())
        
        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - help funcs
    func isStudent() -> Bool {
        
        // check is student

        let role = userToRegister.role
        
        if role == "Student" {
            return true
        }
        
        return false
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - Validator
    /// Error labels
    func hideErrorLabels() {
        
        userFNameErrLabel.text = ""
        userLNameErrLabel.text = ""
        userEmailErrLabel.text = ""
        userPasswordErrLabel.text = ""
        if isStudent() {
            studIDErrLabel.text = ""
        }
    }
    
    func registerValidators() {
        var emailRegexRule = ""
        var emailMessage = ""
        
        switch userToRegister.role {
        case "Professor":
            emailRegexRule = "[A-Z0-9a-z._%+-]+@itu\\.edu"
            emailMessage = "Invalid ITU professor email"
        case "Student":
            emailRegexRule = "[A-Z0-9a-z._%+-]+@students\\.itu\\.edu"
            emailMessage = "Invalid ITU student email"
        default:
            emailRegexRule = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            emailMessage = "Invalid email"
        }
        
        validator.registerField(userFirstNameTextField, errorLabel: userFNameErrLabel, rules: [RequiredRule(), MaxLengthRule(length: 20)])
        validator.registerField(userLastNameTextField, errorLabel: userLNameErrLabel, rules: [RequiredRule(), MaxLengthRule(length: 20)])
        validator.registerField(userEmailTextField, errorLabel: userEmailErrLabel, rules: [RequiredRule(), EmailRule(regex: emailRegexRule, message: emailMessage)])
        validator.registerField(userPasswordTextField, errorLabel: userPasswordErrLabel, rules: [RequiredRule(), MinLengthRule(length: 7)])
        
        if isStudent() {
            validator.registerField(studentIDTextField, errorLabel: studIDErrLabel, rules: [RequiredRule(), RegexRule(regex: "\\d{5}", message: "Invalid student ID")])
        }
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
    
    func validationSuccessful() {
        // submit the form
        print("Validation Successful")
        
        hideKeyboard()
        
        registerUserToServer()

    }
    
    /**
     Register Professor / Student
     
     1. request with credentials to register user
     2. update registered user with email, first name, last name
     3. handle the message
        1. if error, handle error message
        2. if success, handle the json returned, with email, first name, last name, and course information
    */
    func registerUserToServer() {
        
        let credentials = [
            "email": userEmailTextField.text!,
            "password": userPasswordTextField.text!
        ]
        
        // Regester request
        requester.registerUser(.Register, credentials: credentials,
            failureCallback: { (response) -> Void in
                
                Utils.alert("Register Professor Failed",
                    message: "Professor\n \(self.userToRegister.description)", okAction: "OK")
            },
            successCallback: { (response) -> Void in // request success
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    let token = json["token"]
                    
                    if token != nil {
                        
                        self.userToRegister.token = token.string!
                        
                    }
                    
                    
                    var information:[String:AnyObject] = [
                        "email" : self.userEmailTextField.text!,
                        "first_name": self.userFirstNameTextField.text!,
                        "last_name": self.userLastNameTextField.text!,
                    ]
                    
                    if self.isStudent() {
                        
                        self.saveCurrentUserInfo(true)
                        // TODO: wrap optionals
                        information["gender"] = self.userToRegister.gender!
                        information["courses"] = [String]()
                        // information["student_id"] = self.userToRegister.studentID!
                        
                    } else {
                        
                        self.saveCurrentUserInfo()
                        
                    }
                    
                    print("RegisterUser:")
                    print(information)
                    print(credentials)
                    
                    
                    
                    switch res.statusCode {
                        
                    case 400: // User exists
                        
                        let message = json.string!
                        
                        Utils.alert("Failed", message: message)
                        
                    case 201: // User added
                        
                        let token = self.userToRegister.token!
                        
                        // TODO: save token
                        UserManager.sharedInstance.info.token = token
                        
                        self.requester.updateUser(( self.isStudent() ? .Student : .Professor), token: token, parameters: information, failureCallback: { (response) -> Void in
                            
                            // no response body
                            Utils.alert("Update information failed", message: "Something went wrong in register-updateUser")
                            
                            }, successCallback: { (response) -> Void in
                                
                                let json = JSON(data: response.data!)
                                switch response.response!.statusCode {
                                case 201: // User added
                                    
                                    let email = json["email"].string!
                                    let firstName = json["first_name"].string!
                                    let lastName = json["last_name"].string!
                                    
                                    if self.isStudent() {
                                        
                                        if let gender = json["gender"].string {
                                            
                                            // 
                                            print("Gender saved:\(gender)")
                                            
                                        }

                                        /* no student ID for this version
                                        if let studentID = json["student_id"].string {
                                            
                                            //
                                            print("studentID saved:\(studentID)")
                                        }
                                        */
                                        
                                        print(email,firstName, lastName)
                                        
                                        UserManager.sharedInstance.info = self.userToRegister
                                        
                                        self.saveProfileImage()
                                        
                                        // set user flag
                                        self.userDefaults.set( Foundation.Date(), forKey: UDKeys.isNewUser )
                                        self.userDefaults.set( email, forKey: UDKeys.uname )
                                        
                                        self.performSegue(withIdentifier: "registerStudentNext", sender: self)
                                        
                                    } else {
                                     
                                        print(email,firstName, lastName)

                                        UserManager.sharedInstance.info = self.userToRegister
                                        
                                        self.saveProfileImage()
                                        
                                        // set user flag
                                        self.userDefaults.set( Foundation.Date(), forKey: UDKeys.isNewUser )
                                        self.userDefaults.set( email, forKey: UDKeys.uname )
                                        
                                        self.performSegue(withIdentifier: "regProfToDash", sender: self)
                                        
                                    }
                                    

                                default:
                                    print(response.response!.statusCode, "not handled. - register -> update user ")
                                }
                        })
                        
                    default:
                        print(res.statusCode, "not handled. - register user")
                    }
                    
                    
                }
                
        })
    }
    
    func validationFailed(_ errors:[UITextField:ValidationError]) {
        print("Validation Failed")
    }
    
    // MARK: - Go to next field
    func registerNextFields(_ isStudent: Bool) {
        
        self.userFirstNameTextField.delegate = self
        self.userLastNameTextField.delegate = self
        self.userEmailTextField.delegate = self
        self.userPasswordTextField.delegate = self
        
        textFields = [
            userFirstNameTextField,
            userLastNameTextField,
            userEmailTextField,
            userPasswordTextField
        ]
        
        //        if isStudent {
        //            self.studentIDTextField.delegate = self
        //            textFields.append(studentIDTextField)
        //        }
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
                //                else { // last item
                //                    currentTextField.resignFirstResponder()
                //                    // do submit stuff
                //                    Utils.alert("Alert", message: "Submit")
                //                }
            }
        }
        
        return true
    }
    
    // MARK: - User actions
    @IBAction func chooseImagePressed(_ sender: AnyObject) {
        
        imagePicker.allowsEditing = true
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func saveCurrentUserInfo(_ isStudent: Bool? = false) {
        
        userToRegister.firstName = userFirstNameTextField.text!
        userToRegister.lastName = userLastNameTextField.text!
        userToRegister.email = userEmailTextField.text!
        userToRegister.password = userPasswordTextField.text!
        
        if isStudent ?? false {
            userToRegister.studentID = studentIDTextField.text!
            setUserGender()
        }
    }
    
    // TODO: save profile image to device
    func saveProfileImage() {
        
    }
    
    // MARK: -Student actions
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
        // validation of all fields
        
        validator.validate(self)
        
    }
    
    func setUserGender() -> String {
        let selectedSegment = Genders(rawValue: studentGenderSegment.selectedSegmentIndex)!
        switch selectedSegment {
        case .male:
            userToRegister.gender = 1
            return "1"
        case .female:
            userToRegister.gender = 2
            return "2"
        }
    }
    
    // MARK: - Professor actions
    @IBAction func submitProfessorRegisterPressed(_ sender: AnyObject) {
        
        validator.validate(self)
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "registerStudentNext"
        {
            saveCurrentUserInfo(isStudent())
            
            // destination
            let svc = segue.destination as! RegisterStudentViewController
            
            // set destination course
            svc.userToRegister = userToRegister
            
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        userProfileImageView.image = chosenImage.RBResizeImage(chosenImage, targetSize: CGSize(width: 128*3, height: 128*3))
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}
