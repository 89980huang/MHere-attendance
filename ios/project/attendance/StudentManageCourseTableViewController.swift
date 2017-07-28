//
//  StudentManageCourseTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/16/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class StudentManageCourseTableViewController: UITableViewController {

    let cellIdentifier = "classCell"
    let requester = RequestHelper()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData() {
        updateCourseList()
    }
    
    func updateCourseList() {
        
        guard let email = self.userDefaults.string(forKey: UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        if let token = UserManager.sharedInstance.info.token {
        
            self.requester.getUserAllCourses(.Student, token: token, email: email) { (response) -> Void in
                
                let json = JSON(data: response.data!)
                
                switch response.response!.statusCode {
                case 200:
                    
                    let courses = json.arrayValue.map({ $0 })
                    
                    log.info("all course data \(courses)")
                    
                    CourseManager.sharedInstance.studentCourseData = courses.map({ Course.JSONtoCourse($0) })
                    
                    self.tableView.reloadData()
                    
                default:
                    log.warning("Code \(response.response!.statusCode) not handled.")
                }
            }
        } else {
            log.error("Token not set, abort get all courses")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if CourseManager.sharedInstance.studentCourseData.isEmpty {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "You have no course"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
        } else {
            
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            
        }
        
        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CourseManager.sharedInstance.studentCourseData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ClassCell

        let course = CourseManager.sharedInstance.studentCourseData[indexPath.row] as Course
        
        cell.course = course

        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .Delete {
//            
//            
//            
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle(), title: "Delete") {
            action, index in
            
            // Delete the row from the data source
            let message = "Do you want to delete this course?"
            
            Utils.alert("Warning", message: message, okAction: nil, cancelAction: "Cancel", deleteAction: "Delete") { (action) -> Void in
                
                Utils.beginHUD()
                self.tableView.beginUpdates()
                
                let currentCourses = CourseManager.sharedInstance.studentCourseData.map({ $0.getCourseKey() })
                
                let courseToDelete = CourseManager.sharedInstance.studentCourseData[indexPath.row]
                
                CourseManager.sharedInstance.studentCourseData.remove(at: indexPath.row)
                
                guard let token = UserManager.sharedInstance.info.token else {
                    
                    log.error("Token not set. Unable to delete")
                    return
                }
                
                let email = UserManager.sharedInstance.info.email
                
                if email.isEmpty {
                    
                    log.error("Email not set. Unable to delete")
                    return
                }
                
                let newCourses = currentCourses.filter({ $0 != courseToDelete.getCourseKey() })
                
                var info = [String:AnyObject]()
                info["courses"] = newCourses
                
                self.requester.updateUser(.Student, token: token, parameters: info, email: email, failureCallback: { (response) -> Void in
                    log.error("addCourse student - failed to connect")
                    }, successCallback: { (response) -> Void in
                        
                    Utils.endHUD()
                    Utils.alert("Delete course", message: "Course deleted.")
                        
                })
                
                // TODO: send delete request to the server
                tableView.deleteRows(at: [indexPath], with: .left)
                self.tableView.endUpdates()
                // self.reloadData()
            }
        }
        
        let checkIn = UITableViewRowAction(style: .normal, title: "Check In") { action, index in
            
            self.performSegue(withIdentifier: "fromStudentManageToCheckIn", sender: indexPath)
            
        }
        checkIn.backgroundColor = UIColor.orange
        
        return [delete, checkIn]
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        if CourseManager.sharedInstance.studentCourseData.count >= 4 {
            Utils.alert("Classes", message: "You have \(CourseManager.sharedInstance.studentCourseData.count) classes now")
        } else {
            // self.performSegueWithIdentifier("studentAddCourse", sender: self)
        }
        
        self.performSegue(withIdentifier: "studentAddCourse", sender: self)
    }
    
    @IBAction func unwindToStudentManageCourse(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "studentShowCourseDetail" {
            
            let svc = segue.destination as! ClassDetailTableViewController
            let path = self.tableView.indexPathForSelectedRow!
            svc.selectedCourse = CourseManager.sharedInstance.studentCourseData[path.row]
        }
        
        if segue.identifier == "fromStudentManageToCheckIn" {
            
            // destination
            let svc = segue.destination as! StudentCheckInViewController
            
            let indexPath = sender!
            svc.selectedCourse = CourseManager.sharedInstance.studentCourseData[indexPath.row]
        }
    }
    

}
