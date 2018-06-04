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
    
    // MARK: Constants
    let userDefaultService = UserDefaultsService.init()
    let center = UNUserNotificationCenter.current()
    let NOTIFICATION_SETUP = "notificationsAreSetup"
    var dailyReminderTime: Int { get { return 19 }}
    
    // MARK: Functions
    func configureNotifications() {
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("printing requests")
                print(request)
            }
        })
        
        if areNotificationsInitialized() {
            print("configureNotifications notification initialized")
            return
        }
        print("configureNotifications notification not initialized")
        initAndStoreNotificationConfiguration()
        
        
    }
    
    func deleteDeliveredNotifications() {
        center.removeAllDeliveredNotifications()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("printing requests")
                print(request)
            }
        })
    }
    
    func initAndStoreNotificationConfiguration() {
        print("initAndStoreNotificationConfiguration started")

        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 19
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
        registerNotificationRequest(with: trigger)
        
        userDefaultService.setValue(with: NOTIFICATION_SETUP, value: true)
        print("initAndStoreNotificationConfiguration finished")
        return
    }
    
    func registerNotificationRequest(with trigger: UNNotificationTrigger) {
        
        let content = mutableNotificationContent()
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: trigger)
        self.center.add(request) { (error) in
            if error != nil {
                print("initAndStoreNotificationConfiguration error occured")
            }
        }
    }
    
    func mutableNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "The rift is closing"
        content.body = "Have a minute for yourself?"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "alarm"
        
        return content
    }
    
    func areNotificationsInitialized() -> Bool {
        if let serviceSetup = userDefaultService.getValue(with: NOTIFICATION_SETUP, of: "Bool") {
            return (serviceSetup as! Bool ? true : false)
        }
        print("key not set")
        return false
    }
    
    func postponeToTomorrow() {
        center.removeAllPendingNotificationRequests()
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        let timeInterval = (24 - hour + dailyReminderTime) * 3600
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)

        registerNotificationRequest(with: trigger)
        
    }
    
    init() {
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.sound, .badge])
        { (granted, error) in
            if(error != nil) {
                print(error!)
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
