//
//  AppDelegate.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let navController = UINavigationController()
        window?.rootViewController = navController
        appCoordinator = AppCoordinator(navigationController: navController)
        appCoordinator?.start()
        window?.makeKeyAndVisible()
        return true
    }

}

