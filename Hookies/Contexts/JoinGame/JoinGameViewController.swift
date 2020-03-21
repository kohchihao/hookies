//
//  JoinGameViewController.swift
//  Hookies
//
//  Created by Tan LongBin on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

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

    @IBAction private func submitButtonTapped(sender: UIButton) {
        guard let lobbyId = lobbyIdField.text else {
            return
        }
        API.shared.lobby.get(lobbyId: lobbyId, completion: { lobby, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard var lobby = lobby else {
                return
            }
            guard let playerId = Auth.auth().currentUser?.uid else {
                return
            }
            guard lobby.lobbyState == .open else {
                return
            }
            lobby.addPlayer(playerId: playerId)
            if lobby.playersId.contains(playerId) {
                self.navigationDelegate?.didPressJoinLobbyButton(in: self, withLobby: lobby)
                self.dismiss(animated: false, completion: nil)
            }
        })
    }

    private func playerJoinedLobby(playerId: String, lobby: Lobby) {

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
