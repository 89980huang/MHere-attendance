//
//  SelectClassTableViewController.swift
//  attendance
//
//  Created by Yifeng on 11/2/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import SwiftyJSON

class GenerateReportTableViewController: UITableViewController {
    
    let cellIdentifier = "classCell"
    let requester = RequestHelper()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        tableView.setContentOffset(CGPointMake(0, -30 ), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if CourseManager.sharedInstance.courseData.isEmpty {
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
        return  CourseManager.sharedInstance.courseData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ClassCell
        
        let course = CourseManager.sharedInstance.courseData[indexPath.row] as Course

        cell.course = course

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let course = CourseManager.sharedInstance.courseData[indexPath.row]
        
        sendReportRequest(course)
        
    }
    
    func sendReportRequest(_ course: Course) {
        
        Utils.beginHUD(withText: "Getting report...")
        
        guard let email = self.userDefaults.string(forKey: UDKeys.uname) else {
            log.warning("User email is empty, user info updating aborted.")
            return
        }
        
        requester.getUserReport(course.getCourseKey(), email: email, failureCallback: { (response) -> Void in
            
            }) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 201:
                        
                        Utils.alert("Reports", message: "Report for \(course.getCourseKey()) is sent to your email. ")
                        Utils.endHUD()
                        
                    default:
                        Utils.alert("Manual Attendance Error", message: "\(json.stringValue) \nCode \(res.statusCode)")
                        Utils.endHUD(false)
                    }
                }
        }
        
        
        let message = "Report for \(course.getCourseKey()) is sent to your email. "
        
        Utils.alert("Attendance", message: message)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //    var backViewController : UIViewController? {
    //
    //        var stack = self.navigationController!.viewControllers as Array
    //
    //        for (var i = stack.count-1 ; i > 0; --i) {
    //            if (stack[i] as UIViewController == self) {
    //                return stack[i-1]
    //            }
    //
    //        }
    //        return nil
    //    }
}
