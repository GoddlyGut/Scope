//
//  AppDelegate.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UISheetPresentationControllerDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.isTranslucent = true
                // Create instances of view controllers for each tab
                let firstVC = ViewController()
                let secondVC = FullCourseListViewController()
                let thirdVC = SettingsViewController()

                // Embed each view controller in a navigation controller
                let firstNavVC = UINavigationController(rootViewController: firstVC)
                let secondNavVC = UINavigationController(rootViewController: secondVC)
                let thirdNavVC = UINavigationController(rootViewController: thirdVC)

                // Assign tab bar items with titles and icons
                firstNavVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
                secondNavVC.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: "list.clipboard.fill"), tag: 1)
                thirdNavVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)

                // Set the view controllers for the tab bar
                tabBarController.viewControllers = [firstNavVC, secondNavVC, thirdNavVC]
        
        

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.scope.updateCourseStatus", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
                }
        
        NotificationManager.shared.requestNotificationPermission { granted in
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications denied")
            }
        }
        
        let openAppAction = UNNotificationAction(identifier: "OPEN_APP_ACTION", title: "Open App", options: .foreground)
        let category = UNNotificationCategory(identifier: "OPEN_APP_CATEGORY", actions: [openAppAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])

        UNUserNotificationCenter.current().delegate = self
        
        window?.rootViewController = tabBarController
        return true
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleAppRefresh()

        // Perform the background update
        CourseViewModel.shared.checkAndUpdateCourseStatus()

        // Mark the task as complete
        task.setTaskCompleted(success: true)
    }
    
    
    
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.scope.updateCourseStatus")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10) // Schedule to refresh 15 minutes later

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }


    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Called when a notification is tapped, this will ensure the app opens
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Check if the notification action is the default tap (open the app)
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier || response.actionIdentifier == "OPEN_APP_ACTION" {
            // Here, you can optionally handle navigation logic, e.g., open a specific view
//
//            // Example: Navigating to the main view controller
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? ViewController {
//                if let window = UIApplication.shared.windows.first {
//                    window.rootViewController = UINavigationController(rootViewController: mainVC)
//                    window.makeKeyAndVisible()
//                }
//            }
        }

        completionHandler()
    }
}

