//
//  NotificationManager.swift
//  Scope
//
//  Created by Ari Reitman on 9/21/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Request Notification Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            completion(granted)
        }
    }

    // MARK: - Schedule Notification for a Specific Course
    func scheduleNotification(for courseName: String, at startTime: Date) {
        // Ensure we are scheduling in the future
        let timeInterval = startTime.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("Cannot schedule notification for a past date")
            return
        }

        // Generate a unique identifier based on the course name and start time
        let notificationIdentifier = "\(courseName)_\(startTime.timeIntervalSince1970)"

        // Check if the notification is already scheduled
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Check if a notification with the same identifier already exists
            if requests.contains(where: { $0.identifier == notificationIdentifier }) {
                print("Notification for \(courseName) at \(startTime) is already scheduled.")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Upcoming Class"
            content.body = "\(courseName) is starting in 2 minutes!"
            content.sound = .default
            content.categoryIdentifier = "OPEN_APP_CATEGORY"

            // Trigger the notification 2 minutes before the class start time
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval - 120, 1), repeats: false)

            // Create the notification request with the unique identifier
            let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

            // Add the notification request
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                } else {
                    print("Notification scheduled for course \(courseName) at \(startTime)")
                }
            }
        }
    }


    // MARK: - Schedule Notifications for All Courses of the Day
    func scheduleNotifications(for courses: [(courseName: String, startTime: Date)]) {
//        // First, clear all previous notifications to avoid duplicates
        clearAllPendingNotifications()

        for course in courses {
            scheduleNotification(for: course.courseName, at: course.startTime)
        }
    }

    // MARK: - Clear All Notifications
    func clearAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cleared all pending notifications")
    }

    // MARK: - List All Scheduled Notifications (for debugging)
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Scheduled notifications:")
            for request in requests {
                print("ID: \(request.identifier), Content: \(request.content.title)")
            }
        }
    }
}
