//
//  NotificationManager.swift
//  Buszzz
//
//  Created by Calios on 23/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UserNotifications

struct Identifiers {
    static let reminderCategory = "reminder"
    static let approvedAction = "approved"
}

final class NotificationManager: NSObject {
    static let sharedInstance = NotificationManager()

    public func setupNotificationSettings() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, error) in
                if !granted {
                    UIAlertController.showAuthorizationAlert(message: "你没有开启通知，将无法接受到站提醒。请开启后操作！")
                }
            })
        }
        else {
            if (UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)! {
                UIAlertController.showAuthorizationAlert(message: "你没有开启通知，将无法接受到站提醒。请开启后操作！")
            }
        }        
    }
    
    public func registerNotification() {
        if #available(iOS 10.0, *) {
            let buzz = UNNotificationAction(identifier: Identifiers.approvedAction,
                                            title: "准奏！",
                                            options: [.foreground])
            let category = UNNotificationCategory(identifier: Identifiers.reminderCategory,
                                                  actions: [buzz],
                                                  intentIdentifiers: [],
                                                  options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
        }
        else {
            let buzz = UIMutableUserNotificationAction()
            buzz.identifier = Identifiers.approvedAction
            buzz.title = "准奏！"
            buzz.activationMode = UIUserNotificationActivationMode.background
            buzz.isDestructive = false
            buzz.isAuthenticationRequired = false
            
            let actionsArray = NSArray(object: buzz)
            let buzzReminderCategory = UIMutableUserNotificationCategory()
            buzzReminderCategory.identifier = Identifiers.reminderCategory
            buzzReminderCategory.setActions(actionsArray as? [UIUserNotificationAction], for: UIUserNotificationActionContext.default)
            
            let newNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: NSSet(objects: buzzReminderCategory) as? Set<UIUserNotificationCategory>)
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
        }
    }

    public func createReminderNotification(for location:Location) {
        if #available(iOS 10.0, *) {
            createSingleBuzz(location: location, interval: 1)
            createSingleBuzz(location: location, interval: 2)
            createSingleBuzz(location: location, interval: 3)
            createSingleBuzz(location: location, interval: 4)
            createSingleBuzz(location: location, interval: 5)
        }
        else {
            UIApplication.shared.cancelAllLocalNotifications()
            createSingleBuzzz(location: location, interval: 1)
            createSingleBuzzz(location: location, interval: 3)
            createSingleBuzzz(location: location, interval: 5)
            createSingleBuzzz(location: location, interval: 7)
            createSingleBuzzz(location: location, interval: 9)
        }
    }

    public func removeReminderNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
        else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    @available(iOS 10.0, *)
    private func createSingleBuzz(location: Location, interval: Int) {
        let content = UNMutableNotificationContent()
        content.title = "提醒"
        content.body = "到达\(location.address)附近，请准备下车！"
        content.sound = UNNotificationSound.init(named: "alert.m4a")    // if custom not work, use .default()
        //content.sound = .default()
        content.categoryIdentifier = Identifiers.reminderCategory
        
        let date = Date(timeIntervalSinceNow: TimeInterval(interval))
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let identifier = String(location.locationId) + String(interval)
        
        // Construct the request with the above components.
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Problem adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    // < iOS 10
    private func createSingleBuzzz(location: Location, interval: Int) {
        let buzz = UILocalNotification.init()
        buzz.alertAction = "准奏！"
        buzz.repeatInterval = NSCalendar.Unit.second
        buzz.regionTriggersOnce = false
        buzz.soundName = "alert.m4a"    // if custom not work, use UILocalNotificationDefaultSoundName
        buzz.category = Identifiers.reminderCategory
        buzz.fireDate = Date(timeIntervalSinceNow: TimeInterval(interval))
        DLog("buzz====buzz====buzz==== \(Date())")
        if #available(iOS 8.2, *) {
            buzz.alertTitle = "提醒"
        }
        buzz.alertBody = "到达\(location.address)附近，请准备下车！"
        UIApplication.shared.scheduleLocalNotification(buzz)
    }
}
