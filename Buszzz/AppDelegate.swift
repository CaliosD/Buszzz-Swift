//
//  AppDelegate.swift
//  Buszzz
//
//  Created by Calios on 15/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        /// Notification configs.
        // Set the fetch interval so that it is actually called
        // Default is UIApplicationBackgroundFetchIntervalNever.
         UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(DetectingInterval ?? 5))

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        sleep(1)
        
        /// Initialize configs.
        closeReminder()
        NotificationManager.sharedInstance.setupNotificationSettings()
        NotificationManager.sharedInstance.registerNotification()
        LocationManager.sharedInstance.setupLocationSettings()

        if #available(iOS 9.0, *) {
            /// Launch by quick action.
            var shouldPerformAdditionalDelegateHandling = true
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
                launchedShortcutItem = shortcutItem
                
                // This will block "performActionForShortcutItem:completionHandler" from being called.
                shouldPerformAdditionalDelegateHandling = false
                return shouldPerformAdditionalDelegateHandling
            }
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationManager.sharedInstance.setupNotificationSettings()
        LocationManager.sharedInstance.setupLocationSettings()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        closeReminder()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 9.0, *) {
            guard let shortcut = launchedShortcutItem else {
                return
            }
            
            _ = handleShortcutItem(shortcut)
            launchedShortcutItem = nil
        }
    }
    
    func closeReminder() {
        UIApplication.shared.cancelAllLocalNotifications()
        let nav = window?.rootViewController as! UINavigationController
        let locationListVC = nav.viewControllers[0] as! LocationListTableViewController
        locationListVC.shutdownAllDetecting()
    }
}

// Notification Handlers for < iOS 10
extension AppDelegate {
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     completionHandler: @escaping () -> Void) {
        if notification.category == Identifiers.reminderCategory {
            closeReminder()
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication,
                     didReceive notification: UILocalNotification) {
        if application.applicationState == .active {
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: "提醒", message: notification.alertBody, preferredStyle: .alert)
                let action = UIAlertAction(title: "准奏！", style: .default, handler: { (_) in
                    self.closeReminder()
                })
                alert.addAction(action)
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
 
            })
        }
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == Identifiers.approvedAction {
            let request = response.notification.request
            print("Removing item with identifier \(request.identifier)")
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [request.identifier])
            closeReminder()
        }
        
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        // New in iOS 10, we can show notifications when app is in foreground, by calling completion handler with our desired presentation type.
        completionHandler(.alert)
    }
}

// MARK:- Shortcuts Handlings
@available(iOS 9.0, *)
extension AppDelegate {

    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?{
        set {
            
        }
        get {
            return nil
        }
    }
    
    enum ShortcutIdentifier: String {
        case Search
        case Start
        case Stop
        
        // MARK: - Initializers
        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: ".").last else {
                return nil
            }
            
            self.init(rawValue: last)
        }
        
        // MARK: - Properties
        var type : String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else {
            return false
        }
        
        guard let shortCutType = shortcutItem.type as String? else {
            return false
        }
        
        switch shortCutType {
        case ShortcutIdentifier.Search.type:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchLocationNavigationController")
            window?.rootViewController?.present(searchVC, animated: true, completion: nil)
            break
        case ShortcutIdentifier.Start.type:
            window?.rootViewController?.dismiss(animated: true, completion: nil)
//            if DataManager.sharedInstance.retrieveAllLocations().count > 0 {
//                let nav = window?.rootViewController as! UINavigationController
//                let locationListVC = nav.viewControllers[0] as! LocationListTableViewController
//                locationListVC.tableView.cellForRow(at:)
//            }
            
            
            
            break
        case ShortcutIdentifier.Stop.type:
            window?.rootViewController?.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
        return true
    }
    /*
     Called when the user activates your application by selecting a shortcut on the home screen, except when
     application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
     You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
     callback is used if your application is already launched in the background.
     */
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortCutItem = handleShortcutItem(shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
}
