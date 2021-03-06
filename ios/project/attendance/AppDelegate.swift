//
//  AppDelegate.swift
//  attendance
//
//  Created by Yifeng on 10/26/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import XCGLogger

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /*:
        ## customize app colors
        */

        // change global tint color
        self.window?.tintColor = Colors.greenD1
        
        // change tint color of navigation bar items
        UINavigationBar.appearance().tintColor = Colors.white
        
        // change tint color of navigation bar background
        UINavigationBar.appearance().barTintColor = Colors.greenD2
        
        // change tint color of tool bar items
        UIBarButtonItem.appearance().tintColor = Colors.white
        
        // change tint color of tool bar background
        UIToolbar.appearance().barTintColor = Colors.greenD1
        
        // change tint color of tab bar items
        UITabBar.appearance().tintColor = Colors.greenD2
        
        // change tint color of tab bar background
        UITabBar.appearance().barTintColor = Colors.white
        
        /*
        log.verbose("A verbose message, usually useful when working on a specific problem")
        log.debug("A debug message")
        log.info("An info message, probably useful to power users looking in console.app")
        log.warning("A warning message, may indicate a possible error")
        log.error("An error occurred, but it's recoverable, just info about what happened")
        log.severe("A severe error occurred, we are likely about to crash now")
        */
        log.setup(.debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, fileLogLevel: .debug)
//        log.xcodeColorsEnabled = true
        
        loadUserDefaults()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadUserDefaults() {
        
        if let email = userDefaults.string(forKey: UDKeys.uname) {
            UserManager.sharedInstance.info.email = email
            UserManager.sharedInstance.info.token = userDefaults.string(forKey: UDKeys.token)
        }
    }

}
