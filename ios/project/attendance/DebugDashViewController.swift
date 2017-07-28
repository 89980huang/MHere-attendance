//
//  DashViewController.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/17/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON

class DebugDashViewController: UIViewController,
    CLLocationManagerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    
    let requester = RequestHelper()
    let userDefaults = UserDefaults.standard
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
    }
    
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")

        latLabel.text = locValue.latitude.description
        longLabel.text = locValue.longitude.description
        
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(true)
        
        if userDefaults.object(forKey: UDKeys.isNewUser) == nil { // production
            // show login
            self.performSegue(withIdentifier: "debugShowLogin", sender: self)
        } else {
            
            if let role = userDefaults.string(forKey: UDKeys.userRole) {
                /// TODO: load name, and other user info
                /// TODO: save other user info
                
                UserManager.sharedInstance.info.role = role
                updateUserInfo()
//                prepareTabForRole(role)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        
        // check user role
        print("\n## User Role\n", userDefaults.string(forKey: UDKeys.userRole))
        
        updateUserInfo()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func resetLoginPressed(_ sender: AnyObject) {
        // reset isNewUser flag
        userDefaults.removeObject(forKey: UDKeys.isNewUser)
        userDefaults.removeObject(forKey: UDKeys.userRole)
        userDefaults.removeObject(forKey: UDKeys.uname)
        userDefaults.removeObject(forKey: UDKeys.token)
        print("## Reset user role to \(userDefaults.string(forKey: UDKeys.userRole))")
        performSegue(withIdentifier: "debugShowLogin", sender: self)
    }

    @IBAction func tabsButtonPressed(_ sender: AnyObject) {
        
        if userDefaults.object(forKey: UDKeys.isTester) != nil {
            userDefaults.removeObject(forKey: UDKeys.isTester)
        } else {
            userDefaults.set("Tester", forKey: UDKeys.isTester)
        }
    }

    @IBAction func updateProfTestPressed(_ sender: AnyObject) {
        
        let token = "a4eb2d5118e4076f3b5a2eaaec4414415f0e6a37d40f"
        
        var message = ""
        
        func updateProfessor() {
            let headers = [
                "Authorization": "Token \(token)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let info = [
                "email": "test1001@itu.edu",
                "first_name": "Professor",
                "last_name": "NotStudent"
            ]
            
            Alamofire.request(.POST, "http://23.236.59.88:8000/professor/", parameters: info, headers: headers)
                .responseJSON { response in
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        message = JSON.description
                    }
                    
                    Utils.alert("Request", message: message, okAction: "OK")
            }
            
        }
        
        updateProfessor()
    }

    @IBAction func emotyCourseButtonPressed(_ sender: AnyObject) {

        if CourseManager.sharedInstance.courseData.isEmpty {
            
            // Load Fake Data
            
            CourseManager.sharedInstance.courseData = [
                Course(
                    isWeekend: false,
                    name: "Ruby on Rails",
                    code: "SWE 610",
                    section: "1",
                    room: "406",
                    durationStart: "2015-09-15T00:00:00",
                    durationEnd: "2016-01-04T00:00:00",
                    timeStart:  "2015-01-01T20:00:00",
                    timeEnd:  "2015-01-01T22:00:00",
                    trimester: "Fall 2015",
                    professor: "test1001@itu.edu",
                    dayOfWeek: 0
                ),
                
                Course(
                    isWeekend: false,
                    name: "Software Engineering aa@itu.edu",
                    code: "SWE 500",
                    section: "1",
                    room: "201",
                    durationStart: "2015-09-15T00:00:00",
                    durationEnd: "2016-01-04T00:00:00",
                    timeStart:  "2015-01-01T18:00:00",
                    timeEnd:  "2015-01-01T21:00:00",
                    trimester: "Fall 2015",
                    professor: "aa@itu.edu",
                    dayOfWeek: 1
                ),
                Course(
                    isWeekend: false,
                    name: "Software Engineering aa r1",
                    code: "SWE 500",
                    section: "1",
                    room: "r1",
                    durationStart: "2015-09-15T00:00:00",
                    durationEnd: "2016-01-04T00:00:00",
                    timeStart:  "2015-01-01T18:00:00",
                    timeEnd:  "2015-01-01T21:00:00",
                    trimester: "Fall 2015",
                    professor: "aa@itu.edu",
                    dayOfWeek: 1
                ),
                Course(
                    isWeekend: false,
                    name: "Software Engineering",
                    code: "SWE 500",
                    section: "1",
                    room: "201",
                    durationStart: "2015-09-15T00:00:00",
                    durationEnd: "2016-01-04T00:00:00",
                    timeStart:  "2015-01-01T18:00:00",
                    timeEnd:  "2015-01-01T21:00:00",
                    trimester: "Fall 2015",
                    professor: "test1001@itu.edu",
                    dayOfWeek: 1
                )
            ]

            
        } else {
            
            // Remove all
            CourseManager.sharedInstance.courseData.removeAll()
        }
        
        if CourseManager.sharedInstance.studentCourseData.isEmpty {
            
            // Load Fake Data
            
            if UserManager.sharedInstance.info.token == nil {
                Utils.alert("Alert", message: "Token is empty. Please login first")
            }
            
            CourseManager.sharedInstance.studentCourseData.append(
                Course(
                    isWeekend: false,
                    name: "Course to test check in",
                    code: "CKI 111",
                    section: "1",
                    room: "101",
                    durationStart: Foundation.Date().stringFromDate(Foundation.Date(timeInterval: -60 * 60 , since: Foundation.Date()), format: Config.dateFormatInServer),
                    durationEnd: Foundation.Date().stringFromDate(Foundation.Date(timeInterval: 60 * 60 , since: Foundation.Date()), format: Config.dateFormatInServer),
                    timeStart:  "2015-01-01T00:00:00",
                    timeEnd:  "2015-01-01T23:00:00",
                    trimester: "Fall 2015",
                    professor: "test1001@itu.edu",
                    dayOfWeek: 0
                )
            )
            
            
        } else {
            
            // Remove all
            CourseManager.sharedInstance.studentCourseData.removeAll()
        }

        
    }
    
    @IBAction func userInfoPressed(_ sender: AnyObject) {
    
        Utils.alert("Current User", message: UserManager.sharedInstance.info.description)
    }
    
    /*:
    # test requests
        
    ## example account
    - username
        - test1001@itu.edu
    - password
        - password
    - token
        - a4eb2d5118e4076f3b5a2eaaec4414415f0e6a37d40f
    
    ## modes depending on the textfield
    - rg : registration
    - lg : login
    */
    @IBAction func requestPressed(_ sender: AnyObject) {
        
        var message = ""
        
        let credentials = [
            "email": UserManager.sharedInstance.info.email,
            "password": "password"
        ]
        
        let information = [
            "email": UserManager.sharedInstance.info.email,
            "first_name" : "Yifeng",
            "last_name" : "TestRequest",
            "gender" : ""
        ]
        
        let token = UserManager.sharedInstance.info.token!
        
        let email = credentials["email"]
        
        let infoWithoutEmail = [
            "last_name" : "Huang"
        ]
        
        
        func getCourseType() {
            
            requester.getCourseType("800-1", token: token) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 200:
                        
                        let type = json["courseType"].stringValue
                        log.info("\(type)")
                        
                    default:
                        log.warning("\(res.statusCode) not handled")
                    }
                    
                }
                
            }
        }
        
        func getCourses() {
            requester.getCourses(token) { (response) -> Void in
                let json = JSON(data: response.data!)
                
                var courseList = [String:String]()
                
                for ( _ , object) in json {
                    
                    courseList[object["key"].string!] = object["name"].string!
                }
                
                print(courseList)
                
            }
        }
        
        func updateUser() {
            
            requester.updateUser(.Professor, token: token, parameters: infoWithoutEmail, email: email) { (response) -> Void in
                /*
                {
                courses = ();
                email = "test1001@itu.edu";
                "first_name" = Professor;
                "last_name" = NotStudent;
                }
                */
                
                let json = JSON(data: response.data!)
                
                let courses = json["courses"]
                let email = json["email"]
                let firstName = json["first_name"]
                let LastName = json["last_name"]
                
                var message = ""
                
                if courses != nil {
                    message = message + "\nCourses:\n \(courses.description)\n"
                }
                
                if email != nil {
                    message = message + "\nEmail:\n \(email.string!)\n"
                }
                
                if firstName != nil {
                    message = message + "\nfirstName:\n \(firstName.string!)\n"
                }
                
                if LastName != nil {
                    message = message + "\nLastName:\n \(LastName.string!)\n"
                }
                
                Utils.alert("Data from JSON", message: message)
                
                
                print("\nUpdate called\n")
            }
        }
        
        func updateCourse() {
            
            let info = [
                "email": UserManager.sharedInstance.info.email,
                "first_name": "T\(Foundation.Date().stringFromDate(Foundation.Date(), format: "HHmmss"))",
                "courses": ["800-1"]
            ]
            
            let email = UserManager.sharedInstance.info.email
           
            // TODO: update student course
            
            self.requester.updateUser(.Student, token: token, parameters: info as? [String : AnyObject], email: email, failureCallback: { (response) -> Void in
                print("addCourse student - failed to connect")
                }) { (response) -> Void in
                    
                    let json = JSON(data: response.data!)
                    switch response.response!.statusCode {
                    case 201: // User added
                        
                        let email = json["email"].string!
                        let firstName = json["first_name"].string!
                        let lastName = json["last_name"].string!
                        
                        if let gender = json["gender"].string {
                            
                            //
                            print("Gender saved:\(gender)")
                            
                        }
                        
                        print(email, firstName, lastName)
                        print(json["courses"])
                        
                    default:
                        print(response.response!.statusCode, "not handled. - register -> update user ")
                    }
                    
                    
            }
            
        }
        
        func getCourse(_ key: String) {
            
            
            requester.getCourse(key, token: token) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 200:
                        print(json)
                        
                        let course = Course.JSONtoCourse(json)
                        
                        log.info("Course >\n\(course)")
                        
                    default:
                        log.warning("Code \(res.statusCode) not handled")
                        return
                    }
                }
            }
        }
        
        func getUserAllCourses() {
            
            let email = UserManager.sharedInstance.info.email
            
            requester.getUserAllCourses(.Student, token: token, email: email) { (response) -> Void in
                
                let json = JSON(data: response.data!)
                
                print("all course data \(json)")
            }
            
        }
        
//        getCourse("800-1")
//        getCourse("700-1")
        
        getUserAllCourses()
    }
    
    func updateUserInfo() {

        // num1 < num2 ? DO SOMETHING IF TRUE : DO SOMETHING IF FALSE
        
        if UserManager.sharedInstance.info.firstName.isEmpty && UserManager.sharedInstance.info.lastName.isEmpty {
            nameLabel.text = "John Doe"
        } else {
            nameLabel.text = UserManager.sharedInstance.info.firstName + " " + UserManager.sharedInstance.info.lastName
        }
        
        roleLabel.text = UserManager.sharedInstance.info.role
        
        if UserManager.sharedInstance.info.gender != nil {
            
            genderText.text = UserManager.sharedInstance.info.getGenderString()
            
        } else {
            genderLabel.isHidden = true
            genderText.isHidden = true
        }


        if let date = userDefaults.object(forKey: UDKeys.isNewUser) as? Foundation.Date {
            dateLabel.text = date.stringFromDate(date, format: "MMM d, yyyy H:mm a")
        } else {
            dateLabel.text = "Error"
        }

    }

    @IBAction func unwindToDebugDashboard(_ segue: UIStoryboardSegue) {
        
    }

    @IBAction func switchRolePressed(_ sender: AnyObject) {
        
        var role = ""
        
        if userDefaults.string(forKey: UDKeys.userRole) ==  "Student" {
            role = "Professor"
            userDefaults.setValue(role, forKey: UDKeys.userRole)
        } else {
            role = "Student"
            userDefaults.setValue(role, forKey: UDKeys.userRole)
        }
        
        UserManager.sharedInstance.info.role = role
        
        updateUserInfo()
    }
    
//    func prepareTabForRole(role:String) {
//        
//        if userDefaults.objectForKey(UDKeys.isTester) == nil {
//            
//            if let tabBarController = self.tabBarController {
//                
//                switch role {
//                case "Student":
//                    if tabBarController.viewControllers!.count > 5 {
//                        var viewControllers = tabBarController.viewControllers
//                        viewControllers?.removeAtIndex(1)
//                        viewControllers?.removeAtIndex(1)
//                        viewControllers?.removeAtIndex(1)
//                        tabBarController.viewControllers = viewControllers
//                    }
//                case "Professor":
//                    if tabBarController.viewControllers!.count > 5 {
//                        var viewControllers = tabBarController.viewControllers
//                        viewControllers?.removeAtIndex(4)
//                        viewControllers?.removeAtIndex(4)
//                        tabBarController.viewControllers = viewControllers
//                    }
//                default:
//                    print("no role")
//                }
//            }
//        }
//    }
    
    @IBAction func getClassroomPressed(_ sender: AnyObject) {
         
        requester.getClassrooms() { (response) -> Void in
                
            if let res = response.response {
                
                let json = JSON(data: response.data!)
                
                switch res.statusCode {
                case 400:
                    
                    let message = json.string!
                    Utils.alert("Failed", message: message)
                case 200:
                    
                    var classroomList = [Classroom]()
                    
                    for ( _ , classroom) in json {
                        
                        classroomList.append(Classroom(
                            code: classroom["code"].stringValue,
                            name: classroom["name"].stringValue,
                            radius: classroom["radius"].intValue,
                            type: classroom["center"]["type"].stringValue,
                            coordinates: (
                                classroom["center"]["coordinates"][0].doubleValue,
                                classroom["center"]["coordinates"][1].doubleValue
                            )
                        ))
                    }
                    
                    CourseManager.sharedInstance.classrooms = classroomList
                    print(classroomList)
                    
                default:
                    print(res.statusCode, "not handled. - get classroom")
                }
            }
        }

    }
    
    
    func disablesTab() {

        // Disable a tabbar item
        var tabbarTest: UITabBarItem = UITabBarItem()

        let tabBarControllerItems = self.tabBarController?.tabBar.items
        if let arrayOfTabBarItems = tabBarControllerItems as! AnyObject as? NSArray{

            tabbarTest = arrayOfTabBarItems[3] as! UITabBarItem
            tabbarTest.isEnabled = false

        }

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

class CustomTabBarController: UITabBarController,
    UITabBarControllerDelegate {
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
}
