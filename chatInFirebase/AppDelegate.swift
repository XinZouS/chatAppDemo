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

import FBSDKCoreKit

import CocoaAsyncSocket // for iPv6 ?????? // https://github.com/robbiehanson/CocoaAsyncSocket


let newMessageNotificationIdStr = "newMessageNotificationId"
let newRequestNotificationIdStr = "newRequestNotificationId"
let notiIdAccept = "acceptRequest"
let notiIdReject = "rejectRequest"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {

    var newFriend : User?
    var newMsgVC : NewMessageViewController? 
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // add my main.storyboard by code: ================================
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        //window?.rootViewController = UINavigationController(rootViewController: MessagesViewController())
        let tabBarController = TabBarController() // replace above line, use tabbar;
        UITabBar.appearance().tintColor = buttonColorPurple
        UINavigationBar.appearance().barTintColor = buttonColorPurple
        window?.rootViewController = tabBarController
        
//        registerForLocalNotifications(application: application) // it may cause watchdog timeout, so put it async to try:
        DispatchQueue.main.async {
            self.registerForLocalNotifications(application: application)
        }
        
        FIRApp.configure()
        
        // for facebook login:
        //[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions]
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
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
        guard FIRInstanceID.instanceID().token() != nil else { return }
        guard let token = FIRInstanceID.instanceID().token() else { return }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print(" === Unable to connect with FCM. \(error)")
            } else {
                print(" === Connected to FCM.")
            }
        }
    }
    
    // for receiving notifications: =======================================
    func registerForLocalNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(granted, error) in
                if (granted) {
                    //UIApplication.shared.registerForRemoteNotifications() //// ????? will this on use and crash ??????? replaced by settings:
                    let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(settings)
                }else{
                    if let error = error {
                        print(" - get UNUserNotificationCenter.current().requestAuthorization() failed: \(error)")
                    }
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
        
        // media notification actions: ------------
        let acceptRequest = UNNotificationAction(identifier: notiIdAccept, title: "✅ Accept", options: [])
        let rejectRequest = UNNotificationAction(identifier: notiIdReject, title: "⛔️ Ignore", options: [])
        let category = UNNotificationCategory(identifier: newRequestNotificationIdStr, actions: [acceptRequest, rejectRequest], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories( [category] )

        // normal notification: -------------------
        application.registerForRemoteNotifications()
        application.beginBackgroundTask(withName: "=== beginBackgroundTask: showNotification", expirationHandler: nil)
    }
    
    // handle notification messages when receiving one: -----------
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //--- show newRequest notification -------------------------------
    func secheduleNewRequestNotification() {
        guard let newFriend = self.newFriend, let imgPath = Bundle.main.path(forResource: "yadianwenqing", ofType: "png") else { return }
        
        UNUserNotificationCenter.current().delegate = self
        
        let triggerTimmer = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // set content for notification: 
        let content = UNMutableNotificationContent()
        content.title = "New Friend Request"
        content.subtitle = "\(newFriend.name!) wants to add you as friend."
        content.body = "Do you want to add this new friend?"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = newRequestNotificationIdStr //"newRequestNotificationId"
        
        let url = URL(fileURLWithPath: imgPath)
        do{
            let attachment = try UNNotificationAttachment(identifier: newRequestNotificationIdStr, url: url, options: nil)
            content.attachments = [attachment]
        }catch{
            print(" -- loading notification image fail, AppDelegate.swift: secheduleNewRequestNotification() ")
        }
        // send request
        let request = UNNotificationRequest(identifier: newRequestNotificationIdStr, content: content, trigger: triggerTimmer)
        
        // show notification: 
        print(" -- .removeAllPendingNotificationRequests()")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) { (err) in
            if err != nil {
                print(" -- sending notification image fail, AppDelegate.swift: secheduleNewRequestNotification() \(err)")
            }
        }
    }
    // use UNUserNotificationCenterDelegate, response to selection on buttons in notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let newFriend = self.newFriend, self.newMsgVC != nil else { return }

        print(" --- 0. get response: \(response.actionIdentifier)")
        switch response.actionIdentifier {
        case notiIdAccept:
            print(" --- 1. response: \(notiIdAccept), from newFriend: \(newFriend.name)")
            newMsgVC?.acceptRequest(from: newFriend)
        case notiIdReject:
            print(" --- 2. response: \(notiIdReject), of newFriend: \(newFriend.name)")
            newMsgVC?.rejectRequest(of: newFriend)
        default:
            print(" --- 2. response: \(notiIdReject), of newFriend: \(newFriend.name)")
            newMsgVC?.rejectRequest(of: newFriend)
        }
        
        completionHandler()
    }

    
    //=================================================================

    //=== for facebook login ==========================================
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let optionString = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
        let annotations = options[UIApplicationOpenURLOptionsKey.annotation]
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: optionString, annotation: annotations)
        return handled
    }
    
    
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

