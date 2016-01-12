//
//  AppDelegate.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 15.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import UIKit
import CoreLocation

let kKIMLocationUpdated = "kKIMLocationUpdated"
let kKIMLocationUpdatedKey = "kKIMLocationUpdatedKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var location: CLLocationManager?
    var newsNavController: UINavigationController?
    var mapNavController: UINavigationController?
    var moreNavController: UINavigationController?
    var eventsNavController: UINavigationController?
    var familyTripNavController: UINavigationController?
    var tabController: KTabBarController?
    internal var wantsLocation: Bool = false {
        willSet(newWantsLocation) {
            setupLocationService(newWantsLocation)
        }
    }
    internal var lastLocationUpdate = NSDate(timeIntervalSince1970: 0)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        location = CLLocationManager()
        location?.delegate = self
        location?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        location?.distanceFilter = 50

        let purpleColor = UIColor.kimColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().backgroundColor = purpleColor
        UINavigationBar.appearance().barTintColor = purpleColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        if (UINavigationBar.appearance().respondsToSelector("setTranslucent:")) {
            UINavigationBar.appearance().translucent = false
        }
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UISegmentedControl.appearance().tintColor = purpleColor

        DataModel.sharedInstance // Trigger update

        tabController = KTabBarController()
        let news = NewsListController(nibName: nil, bundle: nil)
        newsNavController = UINavigationController(rootViewController: news)
        let map = MapViewController(nibName: nil, bundle: nil)
        mapNavController = UINavigationController(rootViewController: map)
        let more = MoreScreen(style: UITableViewStyle.Grouped);
        moreNavController = UINavigationController(rootViewController: more);
        let events = EventsListViewController(nibName: nil, bundle: nil)
        eventsNavController = UINavigationController(rootViewController: events)

        // Show and select family trip controller if special project is active
        if DataModel.sharedInstance.specialProject.active {
            let familyTrip = SpecialProjectViewController(nibName: nil, bundle: nil)
            familyTripNavController = UINavigationController(rootViewController: familyTrip)
            familyTripNavController?.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)
            tabController?.viewControllers = [eventsNavController!, mapNavController!, familyTripNavController!, newsNavController!, moreNavController!]
            tabController?.selectedIndex = 2
            tabController?.specialProjectEnabled = true
        } else {
            tabController?.viewControllers = [eventsNavController!, mapNavController!, newsNavController!, moreNavController!]
        }

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = tabController
        tabController?.tabBar.translucent = false
        tabController?.tabBar.tintColor = purpleColor
        tabController?.delegate = self
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

    internal func requestLocationPermissions() {
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            if let loc = location {
                if #available(iOS 8.0, *) {
                    loc.requestWhenInUseAuthorization()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }

    func setupLocationService(enabled: Bool) {
        if #available(iOS 8.0, *) {
            if (enabled && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
                location?.startUpdatingLocation()
            } else {
                location?.stopUpdatingLocation()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: CLLocationDelegate

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if #available(iOS 8.0, *) {
            if (status == .AuthorizedWhenInUse && wantsLocation) {
                setupLocationService(true)
            } else {
                setupLocationService(false)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if NSDate().timeIntervalSinceDate(lastLocationUpdate) > 3 * 60 {
            if let lastLocation = locations.last {
                let userInfo = [kKIMLocationUpdatedKey: lastLocation]
                NSNotificationCenter.defaultCenter().postNotificationName(kKIMLocationUpdated, object: self, userInfo:userInfo)
            }
        }
    }

    // MARK: UITabBarControllerDeleagate

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController == tabBarController.selectedViewController {
            switch viewController {
            case eventsNavController!:
                eventsNavController?.popToRootViewControllerAnimated(true)
                if let events = eventsNavController?.viewControllers.first as? EventsListViewController {
                    events.scrollToTop()
                }
            case mapNavController!:
                mapNavController?.popToRootViewControllerAnimated(true)
            case moreNavController!:
                moreNavController?.popToRootViewControllerAnimated(true)
            case newsNavController!:
                newsNavController?.popToRootViewControllerAnimated(true)
                if let news = newsNavController?.viewControllers.first as? NewsListController {
                    news.scrollToTop()
                }
            default:
                return true
            }
        }

        return true
    }
}

