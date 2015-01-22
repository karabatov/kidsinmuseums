//
//  AppDelegate.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 15.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var newsNavController: UINavigationController?
    var mapNavController: UINavigationController?
    var tabController: UITabBarController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyDkk0lJ-Jfyf23-5vCsMalZClkjW3feirE")
        let purpleColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().backgroundColor = purpleColor
        UINavigationBar.appearance().barTintColor = purpleColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        tabController = UITabBarController()
        var news = NewsListController(nibName: nil, bundle: nil)
        newsNavController = UINavigationController(rootViewController: news)
        var map = MapViewController(nibName: nil, bundle: nil)
        mapNavController = UINavigationController(rootViewController: map)
        tabController?.viewControllers = [mapNavController!, newsNavController!]
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = tabController
        tabController?.tabBar.translucent = false
        tabController?.tabBar.tintColor = purpleColor
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

