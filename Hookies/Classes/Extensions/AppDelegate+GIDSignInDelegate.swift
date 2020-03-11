//
//  AppDelegate+GIDSignInDelegate.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

extension AppDelegate: GIDSignInDelegate {

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil, let authentication = user.authentication else {
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil, let result = authResult else {
                return
            }

            API.shared.user.get(withUid: result.user.uid) { user, error in
                guard error == nil, user != nil else {
                    return
                }
                self.appCoordinator?.navigateToHome()
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        appCoordinator?.navigateToAuth()
    }
}
