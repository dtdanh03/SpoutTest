//
//  AppDelegate.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = BaseNavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

