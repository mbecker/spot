//
//  AppDelegate.swift
//  Spot
//
//  Created by Mats Becker on 11/6/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit

import Firebase
import FirebaseMessaging
import FirebaseDatabase

import AsyncDisplayKit
import UserNotifications

import FBSDKCoreKit         // facebook

import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Delete realm database file
        // try! FileManager.default.removeItem(at: Realm.Configuration().fileURL!)
        
        // set badge count to 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            
            print("--- START register_for_notifications ---")
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.rootViewController = MainASTabBarController()
        window.makeKeyAndVisible()
        self.window = window
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // [START disconnect_from_fcm]
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        // [END disconnect_from_fcm]
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation] ?? []
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    
    /*
     * FIREBASE MESSAGING
     */
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        print("--- didReceiveRemoteNotification ---")
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        print("--- didReceiveRemoteNotification: fetchCompletionHandler ---")
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print(userInfo)
    }
    // [END receive_message]
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        print("--- tokenRefreshNotification ---")
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        print("--- connectToFcm ---")
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
        
        print("--- tokenRefreshNotification ---")
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
    }
    // [END connect_to_fcm]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("--- didFailToRegisterForRemoteNotificationsWithError ---")
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("--- didRegisterForRemoteNotificationsWithDeviceToken ---")
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }

}

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("--- userNotificationCenter - willPresent notification ---")
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        let content: UNNotificationContent = notification.request.content
        print("...userInfo - apps ...")
        print("content.title: " + content.title)
        print("content.body: " + content.body)
        print("----")
        if let aps = userInfo["aps"] as? [String: Any] {
            if let notification = aps["alert"] as? [String: Any] {
                // access nested dictionary values by key
                print("aps.alert.body: \(notification["body"]!)")
                print("aps.alert.title: \(notification["title"]!)")
            }
        }
        print("-- Animal")
        if let animal = userInfo["animalid"] as? String {
            print("Animal id: \(animal)")
        }
        
        print("----")
        print(userInfo)
        
        print("-- response content.categoryIdentifier ---")
        print(content.categoryIdentifier)
    }
    
    // background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("--- userNotificationCenter - didReceive ---")
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("...userInfo - apps ...")
        print(userInfo)
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // user clicked on notification
            // user swiped to unlock
            print("...Default identifier...")
            
        case "show":
            // the user tapped our "show more info…" button
            print("...Show more information…")
            
            break
            
        default:
            break
        }
        
        print("-- response ---")
        print(response)
    }
    
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("--- FIRMessagingDelegate - applicationReceivedRemoteMessage ---")
        print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]

