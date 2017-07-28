//
//  ClassDetailTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/21/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClassDetailTableViewController: UITableViewController {

    @IBOutlet weak var isWeekendSwitch: UISwitch!
    @IBOutlet weak var courseNameText: UITextField!
    @IBOutlet weak var courseCodeText: UITextField!
    @IBOutlet weak var courseSectionText: UITextField!
    @IBOutlet weak var courseRoomText: UITextField!
    
    @IBOutlet weak var trimesterText: UITextField!
    @IBOutlet weak var timeStartText: UITextField!
    @IBOutlet weak var timeEndText: UITextField!
    @IBOutlet weak var durationStartText: UITextField!
    @IBOutlet weak var durationEndText: UITextField!
    
    @IBOutlet weak var dayOfWeekText: UITextField!
    @IBOutlet weak var selectedDatesText: UITextField!
    
    var selectedCourse: Course?
    var isWeekendChecked: Bool = false
    
    let fieldsForWeekend = [6,7]
    let fieldsForWeekday = [5]
    let timeFormat = "h:mm a"
    let dateFormat = "MMM d, yyyy"
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let requester = RequestHelper()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedCourse!.getCourseKey()
        
        if let course = selectedCourse {
            isWeekendChecked = course.isWeekend
            displayCourseDetails(course)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let course = selectedCourse {
            isWeekendChecked = course.isWeekend
            displayCourseDetails(course)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayCourseDetails(_ course: Course) {
        
        isWeekendSwitch.setOn(isWeekendChecked, animated: false)
        
        courseNameText.text = course.name
        
        courseCodeText.text = course.code
        
        courseSectionText.text = course.section
        
        courseRoomText.text = course.room
        
        durationStartText.text = course.durationStart.formatDateStringFromString(toFormat: dateFormat)
        durationEndText.text = course.durationEnd.formatDateStringFromString(toFormat: dateFormat)
        timeStartText.text = course.timeStart.formatDateStringFromString(toFormat: timeFormat)
        timeEndText.text = course.timeEnd.formatDateStringFromString(toFormat: timeFormat)
        
        trimesterText.text = course.trimester
        
        if course.isWeekend {
            
            if let selectedDates = course.selectedDates {
                
                var displayDatesString = ""
                
                selectedDates.forEach({ (date) -> () in
                    displayDatesString += "\(date.stringFromDate(date, format: dateFormat))/"
                })
                
                selectedDatesText.text = displayDatesString.substring(to: displayDatesString.characters.index(displayDatesString.endIndex, offsetBy: -1))
            }
            
        } else {
            
            dayOfWeekText.text = weekdays[course.dayOfWeek!]
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isWeekendChecked && indexPath.section == 2 {
            // is weekend, hide weekday
            if fieldsForWeekday.contains(indexPath.row) {
                
                return 0
            }
            
            return super.tableView(tableView, heightForRowAt: indexPath)
            
        } else {
            // is weekday, hide weekend
            if fieldsForWeekend.contains(indexPath.row) {
                
                return 0
            }
            
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    @IBAction func studentGenerateReportPressed(_ sender: AnyObject) {
        
        guard let email = self.userDefaults.string(forKey: UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        Utils.alert("Report Sent", message: "Please check your email for the report.")
        
        // request report
        /*
        requester.getUserReport(selectedCourse!.getCourseKey(), email: email, failureCallback: { (response) -> Void in
                Utils.alert("Error", message: "Unable to connect server.")
            }) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 201:
                        let msg = json.stringValue
                        Utils.alert("Generate report", message: "\(msg)\nCheck your email for latest attendance report.")
                    default:
                        Utils.alert("Error", message: "Unable to make request\nCode \(res.statusCode)")
                        log.error("Code \(res.statusCode) is not handled.")
                    }
                }
        }
*/
    }
    
    @IBAction func unwindToCourseDetail(_ segue: UIStoryboardSegue) {
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editCourseDetail"
        {
            
            // destination
            let svc = segue.destination as! AddCourseTableViewController
            
            // set destination course
            svc.selectedCourse = selectedCourse
            
        }
        
    }


}
