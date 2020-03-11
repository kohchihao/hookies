//
//  SignInViewController.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol SignInNavigationDelegate: class {
    func didSignIn(user: User)
}

class SignInViewController: UIViewController {
    weak var navigationDelegate: SignInNavigationDelegate?
    private var viewModel: SignInViewModelRepresentable

    @IBOutlet private var signInDialog: UIView!
    @IBOutlet private var usernamePromptDialog: UIView!
    @IBOutlet private var userNameField: UITextField!

    // MARK: - INIT
    init(with viewModel: SignInViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: SignInViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }

    @IBAction private func onSubmitButtonClicked(_ sender: Any) {
        guard let username = userNameField.text else {
            return
        }
        viewModel.createAccountWithUsername(username: username) { user, error in
            guard let user = user else {
                if let error = error {
                    self.toast(message: error.errorDescription ?? "Failed to create account")
                }
                return
            }
            self.navigationDelegate?.didSignIn(user: user)
        }
    }
}

extension SignInViewController: SignInViewModelDelegate {
    func toPromptForUsername(isSignedIn: Bool) {
        if isSignedIn {
            signInDialog.isUserInteractionEnabled = true
            usernamePromptDialog.isHidden = true
            usernamePromptDialog.isUserInteractionEnabled = false
        } else {
            signInDialog.isUserInteractionEnabled = false
            usernamePromptDialog.isHidden = false
            usernamePromptDialog.isUserInteractionEnabled = true
        }
    }
}
