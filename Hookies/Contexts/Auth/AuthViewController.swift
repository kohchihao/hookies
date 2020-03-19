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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        toPromptForUsername(toPrompt: viewModel.toPromptForUsername)
        usernamePromptDialog.layer.cornerRadius = 15
    }

    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = (notification as NSNotification).userInfo,
            let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey]
                as? TimeInterval else {
                    return
        }

        var keyboardHeight: CGFloat = 0
        if notification.name == UIResponder.keyboardWillShowNotification {
            guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }

            keyboardHeight = keyboardFrame.cgRectValue.height
        }

        self.usernamePromptDialog.center = CGPoint(x: self.view.frame.width / 2,
                                                   y: (self.view.frame.height - keyboardHeight) / 2)
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
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
