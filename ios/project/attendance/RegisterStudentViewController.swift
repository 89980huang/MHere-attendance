//
//  RegisterStudentViewController.swift
//  attendance
//
//  Created by Yifeng on 11/8/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import ANLongTapButton
import AVFoundation
import SwiftyJSON

class RegisterStudentViewController: UIViewController {
    
    var userToRegister: User?
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var longTapButton: ANLongTapButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var soundFileURL:URL!
    var meterTimer:Timer!
    
    let requester = RequestHelper()
    
    // TODO: change audio settings, change format to IL
    var recordSettings = Config.recordSettings
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = userToRegister {
            
            Utils.alert("Submit Form",
                message: "User Current value: \(user.description)", okAction: "Submit")
            
        } else {
            Utils.alert("Error",
                message: "no user info found", okAction: "OK")
        }
        
        
//        stopButton.enabled = false
//        playButton.enabled = false
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        
        prepareLongTapButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    Utils.alert("Submit Form",
    message: "User Current value: \(userToRegister)", okAction: "Submit")
    
    successStudentRegister()
    */
    
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

                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setActive(false)
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
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    // Recording Button Events
    @IBAction func longPressButtonPressed(_ longTapButton: ANLongTapButton) {
        
        self.recordStart()
        
        longTapButton.didTimePeriodElapseBlock = { () -> Void in
            
            Utils.alert("Times up", message: "Done")
            self.recordStop()
        }
    }
    
    @IBAction func longTapButtonDraggedExit(_ sender: AnyObject) {
        log.info("Long tap drag exited.")
        self.recordStop()
    }
    
    
    @IBAction func longTapButtonReleasedEarly(_ sender: AnyObject) {
        log.info("Long tap released.")
        self.recordStop()
    }
    
    
    func recordStart() {
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordWithPermission(true)
            return
        }
        
        print("recording")
        // update microphone view image status
        //            recorder.record()
        recordWithPermission(false)
    }
    
    func recordStop() {
        if let recorder = recorder, recorder.isRecording {
            print("stop")
            
            recorder.stop()
            
            // debug
            let soundFileInfo: [String:AnyObject]?
            do {
                soundFileInfo = try FileManager.default.attributesOfItem(atPath: soundFileURL.path!)
            } catch _ {
                soundFileInfo = nil
            }
            
            print("soundFileInfo> \(soundFileInfo)")

            meterTimer.invalidate()
    
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
            } catch let error as NSError {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
    }
    
    func uploadAudioFile() {
        
        let date = Foundation.Date().stringFromDate(Foundation.Date(), format: "yyyyMMddHHmmss")
        let fileName = "\(date)iOS.wav"
        print("FileName:", fileName)
        guard let token = UserManager.sharedInstance.info.token else {
            Utils.endHUD(false)
            Utils.alert("Error", message: "No user token found, upload aborted")
            return
        }
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
                        
                        self.successStudentRegister()
                        
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
    
    func successStudentRegister() {
        // set user flag
        userDefaults.set(Foundation.Date(), forKey: UDKeys.isNewUser )
        self.performSegue(withIdentifier: "fromRegisterStudentToDash", sender: self)
        
    }

}

// MARK: AVAudioRecorderDelegate
extension RegisterStudentViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            
            // iOS8 and later
            let alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: {action in
                print("keep was tapped")
                Utils.beginHUD()
                self.uploadAudioFile()
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
extension RegisterStudentViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")

    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
}
