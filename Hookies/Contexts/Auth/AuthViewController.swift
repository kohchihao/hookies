//
//  AuthViewController.swift
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

class AuthViewController: UIViewController {
    weak var navigationDelegate: SignInNavigationDelegate?
    private var viewModel: AuthViewModelRepresentable
    private var loadingView = UIView()
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
    @IBOutlet private var userNameField: UITextField!

    // MARK: - INIT
    init(with viewModel: AuthViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: AuthViewController.name, bundle: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.cleanup()
        super.viewDidDisappear(animated)
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
}

extension AuthViewController: SignInViewModelDelegate {
    func toPromptForUsername(toPrompt: Bool) {
        if toPrompt {
            signInArea.isUserInteractionEnabled = true
            usernamePromptArea.isHidden = true
            usernamePromptArea.isUserInteractionEnabled = false
        } else {
            signInArea.isUserInteractionEnabled = false
            usernamePromptArea.isHidden = false
            usernamePromptArea.isUserInteractionEnabled = true
        }
    }
}
