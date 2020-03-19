//
//  AppDelegate.swift
//  Hookies
//
//  Created by Tan LongBin on 7/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupThirdPartyAuth()
        setupCoordinator()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain
        // types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the
        // application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough
        // application state information to restore your application to its current state in case it is
        // terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can
        // undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }
}

// MARK: - Extension
extension AppDelegate {
    // MARK: PROPERTIES
    var navigationController: UINavigationController {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        return navigationController
    }

    func setupThirdPartyAuth() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }

    // MARK: COORDINATOR
    func setupCoordinator() {
        window = UIWindow()
        guard let window = window else {
            return
        }

        let navigator = Navigator(with: navigationController)
        appCoordinator = AppCoordinator(with: window, navigator: navigator)
        appCoordinator.start()
        window.makeKeyAndVisible()
    }
}
