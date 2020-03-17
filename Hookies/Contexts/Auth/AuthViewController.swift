//
//  AuthViewController.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

protocol SignInNavigationDelegate: class {
    func didSignIn(user: User)
}

class AuthViewController: UIViewController {
    weak var navigationDelegate: SignInNavigationDelegate?
    private var viewModel: AuthViewModelRepresentable
    private var loadingView = UIView()
    private var isSigningIn = false {
        didSet {
            if isSigningIn {
                view.isUserInteractionEnabled = false
                showActivityIndicator(view: view, loadingView: loadingView)
            } else {
                view.isUserInteractionEnabled = true
                removeActivityIndicator(loadingView: loadingView)
            }
        }
    }
    private var isCreatingAccount = false {
        didSet {
            if isCreatingAccount {
                view.isUserInteractionEnabled = false
                showActivityIndicator(view: view, loadingView: loadingView)
            } else {
                view.isUserInteractionEnabled = true
                removeActivityIndicator(loadingView: loadingView)
            }
        }
    }

    @IBOutlet private var signInArea: UIView!
    @IBOutlet private var usernamePromptArea: UIView!
    @IBOutlet private var usernamePromptDialog: UIView!
    @IBOutlet private var usernameField: UITextField!

    // MARK: - INIT
    init(with viewModel: AuthViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: AuthViewController.name, bundle: nil)
        GIDSignIn.sharedInstance().delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        toPromptForUsername(toPrompt: viewModel.toPromptForUsername)
    }

    @IBAction private func onSubmitButtonClicked(_ sender: Any) {
        guard let username = usernameField.text else {
            return
        }
        isCreatingAccount = true
        viewModel.createAccountWithUsername(username: username) { user, error in
            if let error = error {
                self.toast(message: error.errorDescription ?? "Failed to create account")
                self.isCreatingAccount = false
                return
            }
            guard let user = user else {
                self.isCreatingAccount = false
                return
            }
            self.isCreatingAccount = false
            self.navigationDelegate?.didSignIn(user: user)
        }
    }

    private func toPromptForUsername(toPrompt: Bool) {
        if toPrompt {
            signInArea.isUserInteractionEnabled = false
            usernamePromptArea.isHidden = false
            usernamePromptArea.isUserInteractionEnabled = true
        } else {
            signInArea.isUserInteractionEnabled = true
            usernamePromptArea.isHidden = true
            usernamePromptArea.isUserInteractionEnabled = false
        }
    }
}

// MARK: - GIDSignInDelegate
extension AuthViewController: GIDSignInDelegate {
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil, let authentication = user.authentication else {
            return
        }
        isSigningIn = true
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                self.isSigningIn = false
                self.toast(message: error.localizedDescription)
            }
        }
    }
}
