//
//  AppDelegate.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/29/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // add my main.storyboard by code: ================================
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        //window?.rootViewController = UINavigationController(rootViewController: MessagesViewController())
        window?.rootViewController = TabBarController() // replace above line, use tabbar;
        
        FIRApp.configure()
        
        registerForPushNotifications(application: application)
        
        return true
    }

    // for FIRMessiagingDelegate:
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage){
        // for: type appdelegate does not conform to protocol FIRMessagingDelegate
        print("applicationReceivedRemoteMessage: ", remoteMessage)
    }

    // [START refresh_token] =======================================
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // connect to FCM : https://firebase.google.com/docs/cloud-messaging/ios/receive
    func connectToFcm() {
        // Won't connect since there is no token
        // guard FIRInstanceID.instanceID().token() != nil else { return }
        guard let token = FIRInstanceID.instanceID().token() else { return }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("=== Unable to connect with FCM. \(error)")
            } else {
                print("=== Connected to FCM.")
            }
        }
    }
    
    // for receiving notifications: =======================================
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(granted, error) in
                if (granted) {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            // also need func applicationReceivedRemoteMessage() for FIRMessagingDelegate;
            
            // for background fetching msg on device:！！！！！！！！！！！！！！
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            
        } else { //If user is not on iOS 10 use the old methods we've been using
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types:  [.alert, .badge, .sound], categories: nil))
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
    }
    // handle notification messages when receiving one: ============
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        //print(userInfo)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        //print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //=================================================================

    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // for notification msgs;
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM. AppDelegate.swift:applicationDidEnterBackground()")
        
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


}

