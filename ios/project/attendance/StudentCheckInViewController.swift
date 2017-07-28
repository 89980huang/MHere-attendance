//
//  StudentCheckInViewController.swift
//  attendance
//
//  Created by Yifeng on 12/2/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//
///  [reference](https://github.com/genedelisa/AVFoundationRecorder)

import UIKit
import AVFoundation
import CoreLocation
import ANLongTapButton
import SwiftyJSON
import PKHUD

class StudentCheckInViewController: UIViewController {
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    
    @IBOutlet weak var longTapButton: ANLongTapButton!
    
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBOutlet weak var debugControlPanel: UIView!
    @IBOutlet weak var microphoneImage: UIImageView!
    
    @IBOutlet weak var debugSwitch: UISwitch!
    
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    
    var soundFileURL:URL!
    var meterTimer:Timer!
    
    var selectedCourse: Course?
    var courseToCheckIn: Course?
    
    let locationManager = CLLocationManager()
    let requester = RequestHelper()
    var latitude = 0.0
    var longitude = 0.0
    var postitionChecked = false
    
    // TODO: change the current coruse, right now it doesn't detect which course just use the one and only classroom info
    
    var recordSettings = Config.recordSettings
    /*
    
    TODO:
    1. setup recorder & player
    2. display & hide buttons on initilise
    3. start record, update meters
    
    1. setup session
    2. settings
    3. filePath
    4. handle errors
    5. recorder player
    */
    
    @IBAction func debugSwitchChanged(_ sender: AnyObject) {
        
        debugControlPanel.isHidden = !debugSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isEnabled = false
        playButton.isEnabled = false
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        
        prepareLocationManager()
        prepareLongTapButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide debug controls
        debugControlPanel.isHidden = true
        
        if let course = selectedCourse {
//            Utils.alert("Take attendance", message: "has a selected course")
            
            courseToCheckIn = course
            
            let message = "Taking attendance for \(course.getCourseKey())."
            
            Utils.alert("Manual Attendance", message: message)
        } else {
            
            // TODO: based on current time and date to determine

            // Debug
//            let coursesTest = [Course(
//                isWeekend: false,
//                name: "Course to test check in",
//                code: "CKI 111",
//                section: "1",
//                room: "101",
//                durationStart: NSDate().stringFromDate(NSDate(timeInterval: -60 * 60 , sinceDate: NSDate()), format: Config.dateFormatInServer),
//                durationEnd: NSDate().stringFromDate(NSDate(timeInterval: 60 * 60 , sinceDate: NSDate()), format: Config.dateFormatInServer),
//                timeStart:  "2015-01-01T00:00:00",
//                timeEnd:  "2015-01-01T23:00:00",
//                trimester: "Fall 2015",
//                professor: "test1001@itu.edu",
//                dayOfWeek: 0
//                )]
//            
//            let courses = coursesTest.filter(checkCurrentCourse)
            
            // Production
            let courses = CourseManager.sharedInstance.studentCourseData.filter(checkCurrentCourse)
            
            if let firstCourse = courses.first {
                Utils.alert("Current course", message: "Check in for \(firstCourse.getCourseKey())")
                
                courseToCheckIn = firstCourse
                
            } else {
                log.warning("No on-going course found.")
            }
        }
    }
    
    func checkCurrentCourse(_ course: Course) -> Bool {
        
        let userCalendar = Calendar.current
        
        let durationStart = Foundation.Date().dateFromString(course.durationStart, format: Config.dateFormatInServer)
        let durationEnd = Foundation.Date().dateFromString(course.durationEnd, format: Config.dateFormatInServer)
        
        let timeStart = Foundation.Date().dateFromString(course.timeStart, format: Config.dateFormatInServer)
        let timeEnd = Foundation.Date().dateFromString(course.timeEnd, format: Config.dateFormatInServer)
        let timeStartTenMinBefore = (userCalendar as NSCalendar).date(byAdding: [.minute], value: -10, to: timeStart, options: [])!
        let timeEndTenMinAfter = (userCalendar as NSCalendar).date(byAdding: [.minute], value: 10, to: timeEnd, options: [])!
        
        let hourStart = Foundation.Date().stringFromDate(timeStartTenMinBefore, format: "HHmm")
        let hourEnd = Foundation.Date().stringFromDate(timeEndTenMinAfter, format: "HHmm")
        
        let now = Foundation.Date()
        let currentHour = Foundation.Date().stringFromDate(now, format: "HHmm")
        
        log.info("Results for checking course")
        print("durationStart < now : \(durationStart < now)")
        print(" && now < durationEnd : \(now < durationEnd)")
        print(" && hourStart < currentHour : \(hourStart < currentHour)")
        print(" && currentHour < hourEnd : \(currentHour < hourEnd)")
        
        print("course\(course)")
        
        print("timeEnd \(timeEnd)\ntimeEndTenMinAfter \(timeEndTenMinAfter)")
        
        print("4 times,  \(durationStart), \(hourStart) < \(now) , \(hourEnd) \(durationEnd)")
        
        let result = durationStart < now && now < durationEnd && hourStart < currentHour && currentHour < hourEnd
        
//        switch result {
//        case true:
//            Utils.alert("Attendence", message: "found a current course")
//        case false:
//            Utils.alert("Attendence", message: "No on-going course detected")
//        }
        return result
    }
    
    func prepareLocationManager() {
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkLocationDistance(_ location1:(Double, Double), location2: (Double, Double)) -> Double {
        
        let loc1 = CLLocation(latitude: location1.0, longitude: location1.1)
        
        let loc2 = CLLocation(latitude: location2.0, longitude: location2.1)
        
        print("distance: \(loc2.distance(from: loc1))m")
        
        return loc2.distance(from: loc1)
    }
    
    func prepareLongTapButton() {
        
        let titleString = "Record\n"
        let hintString = "Hold to record.\nRelease to stop.\n10 sec max"
        
        let title = NSMutableAttributedString(string: titleString + hintString)
        let titleAttributes = [NSForegroundColorAttributeName: UIColor.white, NSBackgroundColorAttributeName: UIColor.clear, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 22)!]
        let hitAttributes = [NSForegroundColorAttributeName: UIColor.white, NSBackgroundColorAttributeName: UIColor.clear, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 12)!]
        title.setAttributes(titleAttributes, range: NSMakeRange(0, titleString.characters.count))
        title.setAttributes(hitAttributes, range: NSMakeRange(titleString.characters.count, hintString.characters.count))
        
        longTapButton.titleLabel?.lineBreakMode = .byWordWrapping
        longTapButton.titleLabel?.textAlignment = .center
        longTapButton.setAttributedTitle(title, for: UIControlState())
        
        longTapButton.timePeriod = 10
        longTapButton.barColor = Colors.orange
        longTapButton.barTrackColor = Colors.grey
        longTapButton.bgCircleColor = Colors.greenD2
        longTapButton.barWidth = 10
    }
    
    @IBAction func uploadButtonPressed(_ sender: AnyObject) {
        // debug, re-upload voice
        
        guard let token = UserManager.sharedInstance.info.token else {
            Utils.endHUD(false)
            Utils.alert("Error", message: "No user token found, upload aborted")
            return
        }
        
        let date = Foundation.Date().stringFromDate(Foundation.Date(), format: "yyyyMMddHHmmss")
        
        let fileName = "\(date)iOS.wav"
        
        requester.uploadVoiceSample(self.soundFileURL!, token: token, fileName: fileName, failureCallback: { (response) -> Void in
            print("Request Upload connection failed")
            }) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    let message = json.description
                    
                    switch res.statusCode {
                    case 202:
                        Utils.endHUD()
                        Utils.alert("Success", message: message)
                        
                        print("Upload success")
                        print("JSON:", json)
                        
                    case 406:
                        Utils.endHUD(false)
                        print("Upload failed, file exists.")
                        Utils.alert("Success", message: message)
                        
                    default:
                        Utils.endHUD(false)
                        log.error("\(res.statusCode)")
                        Utils.alert("Error", message: "Unable to upload")
                    }
                }
            }


        // Production
        
        /*
        guard let course = self.courseToCheckIn else {
            Utils.alert("Unable to Upload", message: "No course is selected")
            return
        }
        
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        Utils.beginHUD()
        print("waiting for 5 seconds")
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            print("waited for 5 seconds")
            
            self.requester.getClassrooms() { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    switch res.statusCode {
                    case 400:
                        let message = json.string!
                        Utils.alert("Failed", message: message)
                        Utils.endHUD(false)
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
                        
                        classroomList.append(Classroom(code: "yifeng", name: "Yifeng's", radius: 100, type: "point", coordinates: (37.381973, -121.88024899999999)))
                        
                        CourseManager.sharedInstance.classrooms = classroomList
                        print(classroomList)
                        
                        guard let classroom = classroomList.filter({ $0.code == "yifeng" }).first else {
                            log.error("No classroom found, exit")
                            Utils.endHUD(false)
                            return
                        }
                        
                        let coordinates = classroom.coordinates
                            
                         if coordinates.0.isZero || coordinates.1.isZero {
                            log.error("No classroom coordinates found, exit")
                            Utils.endHUD(false)
                            return
                        }

                        var distance = 0.0
                        
                        log.info("coordinates > \(coordinates)")
                        distance = self.checkLocationDistance(coordinates, location2: (self.latitude, self.longitude))
                        
                        // Utils.alert("Distance", message: distance.description)
                        
                        if self.checkValidDistance(classroom, distance: distance) {
                            // within distance
                            print("distance > \(distance), valid")
                            self.uploadAudioFile(course)
                            
                        } else {
                            // outside of valid zone
                            Utils.endHUD(false)
                            print("distance > \(distance), invalid")
                            Utils.alert("Wrong Location", message: "Nice try but be there next time")
                            
                        }
                        
                    default:
                        Utils.endHUD(false)
                        print("\(res.statusCode) not handled - getClassrooms ")
                    }
                }
            }
        })
        */
    }
    
    func sizeForLocalFilePath(_ filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    func  uploadAudioFile(_ course: Course) {
        
        let date = Foundation.Date().stringFromDate(Foundation.Date(), format: "yyyyMMddHHmmss")
        
        let fileName = "\(date)iOS.wav"
//        let fileName = "\(date)iOS.m4a"
        
        print("FileName:", fileName)
        
        guard let token = UserManager.sharedInstance.info.token else {
            Utils.endHUD(false)
            Utils.alert("Error", message: "No user token found, upload aborted")
            return
        }
        
        requester.authVoiceSample(self.soundFileURL!, token: token, courseKey: course.getCourseKey(), fileName: fileName, failureCallback: { (response) -> Void in
            
                log.error("Request Upload connection failed")
                Utils.endHUD(false)
                Utils.alert("Error", message: "Cannot upload file. Connection lost.")
            
            }) { (response) -> Void in
                
                if let res = response.response {
                    
                    let json = JSON(data: response.data!)
                    
                    let message = json.description
                    
                    switch res.statusCode {
                    case 202:
                        
//                        Utils.alert("Showing Result", message: json.description)
                        
                        let score = json["score"].doubleValue
                        
                        if score > 0.7 {
                            Utils.endHUD()
                        } else {
                            Utils.endHUD(false)
                        }
                        
                        Utils.alert("Score", message: String(score * 100))
                        
                        print("Upload success")
                        print("JSON:", json)
                        
                        
                        // TODO: get result from server and display it
                        // and do stuff for a successful or failed validation
                       
                    case 406:
                        Utils.endHUD(false)
                        print("Upload failed, file exists.")
                        Utils.alert("Success", message: message)
                        
                    case 403:
                        Utils.endHUD(false)
                        
                        let score = json["score"].doubleValue
                        
                        Utils.alert("Score", message: String(score * 100))
                        
                        print("Code \(res.statusCode)")
                        
                    default:
                        Utils.endHUD(false)
                        log.error("\(res.statusCode)")
                        Utils.alert("Error Auth Voice", message: "Unable to upload\nCode \(res.statusCode)")
                    }
                }
        }
        
    }
    
    func checkValidDistance(_ classroom: Classroom, distance: Double) -> Bool {
        
        let type = classroom.type.lowercased()
        
        switch type {
            case "point":
                return distance < Double(classroom.radius)
        default:
            return false // for testing
        }
        
    }
    
    // Long tap button
    @IBAction func longTapButtonPressed(_ sender: AnyObject) {
        
        self.recordStart()
        
        longTapButton.didTimePeriodElapseBlock = { () -> Void in
            
            Utils.alert("Times up", message: "Done")
            self.recordStop()
        }
    }
    
    // Long tap button released before defined time
    @IBAction func longTapButtonReleasedEarly(_ sender: ANLongTapButton) {
        // touch up inside/outside
        log.info("Long tap released.")
        self.recordStop()
    }
    
    
    @IBAction func longTapButtonDraggedAway(_ sender: AnyObject) {
        log.info("Long tap drag exited.")
        self.recordStop()
    }
    
    func updateAudioMeter(_ timer:Timer) {
        if recorder.isRecording {
            let dFormat = "%02d"
            let min:Int = Int(recorder.currentTime / 60)
            let sec:Int = Int(11 - recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            statusLabel.text = s
            recorder.updateMeters()
//            let apc0 = recorder.averagePowerForChannel(0)
//            let peak0 = recorder.peakPowerForChannel(0)
//            print(apc0)
//            print(peak0)
            
            if recorder.currentTime > 10 {
                timer.invalidate()
                
                print("stop by 10 seconds")
                
                recorder?.stop()
                
                meterTimer.invalidate()
                
                recordButton.setTitle("Record", for:UIControlState())
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setActive(false)
                    playButton.isEnabled = true
                    stopButton.isEnabled = false
                    recordButton.isEnabled = true
                } catch let error as NSError {
                    print("could not make session inactive")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func play() {
        
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            
            print("file size> \(sizeForLocalFilePath(soundFileURL.path!))")
            
            stopButton.isEnabled = true
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        // TODO: change recording file format
        let currentFileName = "recording-\(format.string(from: Foundation.Date())).wav"
//        let currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        // DEBUG
        print("soundFileURL")
        debugPrint(soundFileURL)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: "requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.statusLabel.text = "00:10"
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                        target:self,
                        selector:"updateAudioMeter:",
                        userInfo:nil,
                        repeats:true)
                } else {
                    log.warning("Permission to record not granted")
                    Utils.alert("Warning: Permission not granted", message: "We need to use your microphone. Plesse go to settings - privacy - microphone to enable it.")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func deleteAllRecordings() {
        let docsDir =
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("wav")
//                return name.hasSuffix("m4a")
            })
            for var i = 0; i < recordings.count; i++ {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
    }
    
    func askForNotifications() {
        
        NotificationCenter.default.addObserver(self,
            selector:"background:",
            name:NSNotification.Name.UIApplicationWillResignActive,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:"foreground:",
            name:NSNotification.Name.UIApplicationWillEnterForeground,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:"routeChange:",
            name:NSNotification.Name.AVAudioSessionRouteChange,
            object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    func routeChange(_ notification:Notification) {
        print("routeChange \(notification.userInfo)")
        
        if let userInfo = notification.userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordButton.setTitle("Pause", for:UIControlState())
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
            recordButton.setTitle("Continue", for:UIControlState())
            
        } else {
            print("recording")
            recordButton.setTitle("Pause", for:UIControlState())
            playButton.isEnabled = false
            stopButton.isEnabled = true
            //            recorder.record()
            recordWithPermission(false)
        }

        
    }
    
    @IBAction func microphoneButtonTouchedDown(_ sender: AnyObject) {
        print("Micro touched")
        
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordButton.setTitle("Pause", for:UIControlState())
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recordWithPermission(true)
            return
        }
        
        print("recording")
        recordButton.setTitle("Pause", for:UIControlState())
        playButton.isEnabled = false
        stopButton.isEnabled = true
        // update microphone view image status
        //            recorder.record()
        recordWithPermission(false)
    }
    
    
    @IBAction func microphoneButtonTouchUpInside(_ sender: AnyObject) {
        print("Micro released")
        
        if let recorder = recorder, recorder.isRecording {
            print("stop")
            
            recorder.stop()
            
            meterTimer.invalidate()
            
            recordButton.setTitle("Record", for:UIControlState())
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
                playButton.isEnabled = true
                stopButton.isEnabled = false
                recordButton.isEnabled = true
            } catch let error as NSError {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
    }
    
    func recordStart() {
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordButton.setTitle("Pause", for:UIControlState())
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recordWithPermission(true)
            return
        }
        
        print("recording")
        microphoneImage.isHighlighted = true
        microphoneImage.tintColor = Colors.orange
        recordButton.setTitle("Pause", for:UIControlState())
        playButton.isEnabled = false
        stopButton.isEnabled = true
        // update microphone view image status
        //            recorder.record()
        recordWithPermission(false)
    }
    
    func recordStop() {
        if let recorder = recorder, recorder.isRecording {
            print("stop")
            
            recorder.stop()
            
            let soundFileInfo: [String:AnyObject]?
            do {
                soundFileInfo = try FileManager.default.attributesOfItem(atPath: soundFileURL.path!)
            } catch _ {
                soundFileInfo = nil
            }
            
            print("soundFileInfo> \(soundFileInfo)")
            
            microphoneImage.isHighlighted = false
            microphoneImage.tintColor = UIColor.black
            meterTimer.invalidate()
            
            recordButton.setTitle("Record", for:UIControlState())
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
                playButton.isEnabled = true
                stopButton.isEnabled = false
                recordButton.isEnabled = true
            } catch let error as NSError {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func playButtonPressed(_ sender: AnyObject) {
        setSessionPlayback()
        play()
    }

    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        
        print("stop")
        
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        recordButton.setTitle("Record", for:UIControlState())
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            playButton.isEnabled = true
            stopButton.isEnabled = false
            recordButton.isEnabled = true
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
        //recorder = nil
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

// MARK: AVAudioRecorderDelegate
extension StudentCheckInViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            stopButton.isEnabled = false
            playButton.isEnabled = true
            recordButton.setTitle("Record", for:UIControlState())
            
            // iOS8 and later
            let alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
                print("keep was tapped")
            
                
            }))
            
            alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: {action in
                print("keep was tapped")
                
                // Production
                guard let course = self.courseToCheckIn else {
                    Utils.alert("Unable to Upload", message: "No course is selected")
                    return
                }
                
//                let seconds = 5.0
                let seconds = 0.0 // development setting
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                
                Utils.beginHUD()
                
                print("waiting for 5 seconds")
                
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    
                    print("waited for 5 seconds")
                    
                    self.requester.getClassrooms() { (response) -> Void in
                        
                        if let res = response.response {
                            
                            let json = JSON(data: response.data!)
                            
                            switch res.statusCode {
                            case 400:
                                let message = json.string!
                                Utils.endHUD(false)
                                Utils.alert("Failed to get classrooms", message: message)

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
                                
                                // Debug
//                                classroomList.append(Classroom(code: "yifeng", name: "Yifeng's", radius: 100, type: "point", coordinates: (37.381973, -121.88024899999999)))
                                
                                CourseManager.sharedInstance.classrooms = classroomList
                                print("Classrooms: \(classroomList)")
                                
                                guard let classroom = classroomList.filter({ $0.code == course.room }).first else {
                                    log.error("No classroom found, exit")
                                    Utils.endHUD(false)
                                    return
                                }
                                
                                let coordinates = classroom.coordinates
                                
                                // Production
                                if coordinates.0.isZero || coordinates.1.isZero {
                                    // Production
//                                    log.error("No classroom coordinates found, exit")
//                                    Utils.endHUD(false)
//                                    Utils.alert("Error", message: "No classroom coordinates found, exit ")
//                                    return
                                    
                                    // Debug
                                    Utils.alert("Warning", message: "Classroom coordinates contain 0 value")

                                }
                                
                                var distance = 0.0
                                
                                log.info("coordinates > \(coordinates)")
                                distance = self.checkLocationDistance(coordinates, location2: (self.latitude, self.longitude))
                                
                                // Utils.alert("Distance", message: distance.description)
                                
                                if self.checkValidDistance(classroom, distance: distance) {
                                    // within distance
                                    print("distance > \(distance), valid")
                                    self.uploadAudioFile(course)
                                    
                                } else {
                                    // outside of valid zone
                                    Utils.endHUD(false)
                                    print("distance > \(distance), invalid")
                                    Utils.alert("Wrong Location", message: "Nice try but be there next time\n Distance: \(distance)m")
                                    
                                }
                                
                            default:
                                Utils.endHUD(false)
                                print("\(res.statusCode) not handled - getClassrooms ")
                            }
                        }
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
                print("delete was tapped")
                self.statusLabel.text = "00:10"
                self.recorder.deleteRecording()
            }))
            self.present(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
        error: Error?) {
            
            if let e = error {
                print("\(e.localizedDescription)")
            }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension StudentCheckInViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        recordButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
}

extension StudentCheckInViewController: CLLocationManagerDelegate {
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        // print("locations = \(locValue.latitude) \(locValue.longitude)")

        latLabel.text = locValue.latitude.description
        longLabel.text = locValue.longitude.description
        
        latitude = locValue.latitude
        longitude = locValue.longitude
        
    }
    
}
