//
//  JoinGameViewController.swift
//  Hookies
//
//  Created by Tan LongBin on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

protocol JoinGameViewNavigationDelegate: class {
    func didPressJoinLobbyButton(in: JoinGameViewController, withLobby: Lobby)
}

class JoinGameViewController: UIViewController {
    weak var navigationDelegate: JoinGameViewNavigationDelegate?
    private var viewModel: JoinGameViewModelRepresentable

    @IBOutlet private var joinGameDialog: UIView!
    @IBOutlet private var lobbyIdField: UITextField!

    init(with viewModel: JoinGameViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: JoinGameViewController.name, bundle: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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

        self.joinGameDialog.center = CGPoint(x: self.view.frame.width / 2, y: (self.view.frame.height - keyboardHeight) / 2)
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        joinGameDialog.backgroundColor = UIColor.clear
        joinGameDialog.isOpaque = false
        joinGameDialog.layer.cornerRadius = 15
    }

    @IBAction private func closeButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // TODO: Retrieve lobby from firestore
    @IBAction private func submitButtonTapped(sender: UIButton) {
        guard let lobbyId = lobbyIdField.text else {
            return
        }
        let lobby = Lobby(hostId: lobbyId)
        print(lobby.hostId)
        self.dismiss(animated: true, completion: nil)
        navigationDelegate?.didPressJoinLobbyButton(in: self, withLobby: lobby)
        self.dismiss(animated: true, completion: nil)
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
}
