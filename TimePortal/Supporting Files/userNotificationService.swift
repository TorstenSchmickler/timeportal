//
//  userNotificationService.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 02/06/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//

import Foundation
import UserNotifications

class UserNotificationService {
    let userDefaultService = UserDefaultsService.init()
    let center = UNUserNotificationCenter.current()
    let NOTIFICATION_SETUP = "notificationsAreSetup"
    
    func configureNotifications() {
        if areNotificationsInitialized() {
            print("configureNotifications notification initialized")
            return
        }
        print("configureNotifications notification not initialized")
        initAndStoreNotificationConfiguration()
        
//        self.center.getPendingNotificationRequests(completionHandler: { requests in
//            for request in requests {
//                print("printing requests")
//                print(request)
//            }
//        })
    }
    
    func initAndStoreNotificationConfiguration() {
        print("initAndStoreNotificationConfiguration started")
        let content = UNMutableNotificationContent()
        content.title = "The rift is closing"
        content.body = "Have a minute for yourself?"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "alarm"

        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 19
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (5), repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        self.center.add(request) { (error) in
            if error != nil {
                print("initAndStoreNotificationConfiguration error occured")
            }
        }
        userDefaultService.setValue(with: NOTIFICATION_SETUP, value: true)
        print("initAndStoreNotificationConfiguration finished")
        return
    }
    
    func areNotificationsInitialized() -> Bool {
        if let serviceSetup = userDefaultService.getValue(with: NOTIFICATION_SETUP, of: "Bool") {
            return (serviceSetup as! Bool ? true : false)
        }
        print("key not set")
        return false
    }
    
    
    init() {
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.sound, .badge])
        { (granted, error) in
            if(error != nil) {
                print(error)
                return
            }
            print("userNotificationService Permissions where granted: \(granted)")
            self.center.getNotificationSettings { (settings) in
                // Do not schedule notifications if not authorized.
                guard settings.authorizationStatus == .authorized else {print("Notifications settings not granted"); return}
                
                    print("Badge and sound granted")
                    self.configureNotifications()

            }   
        }
    }
    
}
