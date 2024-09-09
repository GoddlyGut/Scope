//
//  AppDelegate.swift
//  Scope
//
//  Created by Ari Reitman on 6/22/24.
//

import UIKit

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
        
        

        
        
        
        window?.rootViewController = tabBarController
        return true
    }


}

