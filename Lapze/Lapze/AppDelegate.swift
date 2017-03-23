//
//  AppDelegate.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/1/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import UserNotifications
//import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Simulate Location
        //location()
        //Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyDOiTbYY-vEPH42OMTCp3nlmF4BtoVu7Cc")
        //FireBase Init
        FIRApp.configure()
        
        
        //User Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowd, error) in
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        //Styling
        UILabel.appearance().font = UIFont(name: "Heiti SC", size: 11.0)
        
        
        //MARK: - navbar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
     
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navAppearance = UINavigationBar.appearance()
        navAppearance.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir-Book", size: 16)!, NSForegroundColorAttributeName : UIColor.white]
        navAppearance.barTintColor = ColorPalette.darkPurple
        navAppearance.tintColor = .white
        
        //Root View
        //test
        self.window?.rootViewController = MainTabController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    func location() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
        FirebaseManager.shared.removeEvent()
        FirebaseManager.shared.removeUserLocation()
    }
}

