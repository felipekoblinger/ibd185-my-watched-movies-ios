//
//  AppDelegate.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/21/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import KeychainAccess
import JWTDecode
import CoreStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer: Timer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if AuthenticationHelper.isLogged() {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainUITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "PrincipalUITabBarController") as! PrincipalUITabBarController
            self.window?.rootViewController = mainUITabBarController
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Testing
    @objc func verifyTokenValidity() {
        print("Observer method called")
        postTokenAcquisitionScript();
        //You may call your action method here, when the application did enter background.
        //ie., self.pauseTimer() in your case.
    }
    
    func getToken() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tokenAcquired"), object: nil)
    }
    
    func postTokenAcquisitionScript() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        timer.invalidate()
        getToken()
    }

}
