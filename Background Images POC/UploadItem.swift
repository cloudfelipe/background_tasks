//
//  UploadItem.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    let center = UNUserNotificationCenter.current()
    
    private init() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("Notifications has been declined")
            }
        }
    }
    
    func sheduleNotificationInBackground(title: String) {
        let application = UIApplication.shared
        let backgroundTask = application.beginBackgroundTask(withName: "notificationBackground")
        scheduleNotification(notificationType: title) {
            application.endBackgroundTask(backgroundTask)
        }
    }
    
    func scheduleNotification(notificationType: String, completionHandler: (() -> Void)? = nil) {
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationType
//        content.body = "This is example how to create"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(trigger) { (completed) in
            completionHandler?()
        }
    }
}
