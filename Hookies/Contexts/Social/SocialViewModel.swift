//
//  SocialViewModel.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

protocol SocialViewModelDelegate: class {
    func updateView()
}

protocol SocialViewModelRepresentable {
    var delegate: SocialViewModelDelegate? { get set }
    var social: Social { get }
    var lobbyId: String? { get }
    var inviteEnabled: Bool { get }
    func subscribeToSocial()
    func sendRequest(username: String)
    func sendInvite(username: String)
    func removeFriend(username: String)
    func unsubscribeSocial()
}

class SocialViewModel: SocialViewModelRepresentable {
    weak var delegate: SocialViewModelDelegate?
    var social: Social
    var inviteEnabled: Bool
    var lobbyId: String?

    // MARK: Init
    init(lobbyId: String?) {
        guard let currentUser = API.shared.user.currentUser else {
            fatalError("Host is not logged in")
        }
        self.social = Social(userId: currentUser.uid)
        self.lobbyId = lobbyId
        self.inviteEnabled = lobbyId != nil
    }

    // MARK: Social Store
    func subscribeToSocial() {
        guard let currentUser = API.shared.user.currentUser else {
            return
        }
        API.shared.social.subscribeToSocial(userId: currentUser.uid, listener: { social, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let updatedSocial = social else {
                return
            }
            self.social = updatedSocial
            self.delegate?.updateView()
        })
    }

    func unsubscribeSocial() {
        API.shared.social.unsubscribeFromSocial()
    }

    // MARK: Game Invite

    /// Send game invite to user with username
    /// - Parameter username: username of the receipient user
    func sendInvite(username: String) {
        guard inviteEnabled else {
            return
        }
        guard let fromUserId = API.shared.user.currentUser?.uid else {
            Logger.log.show(details: "user is not logged in", logType: .error)
            return
        }
        API.shared.user.get(withUsername: username, completion: { user, error in
            guard error == nil else {
               Logger.log.show(details: error.debugDescription, logType: .error)
               return
            }
            guard let toUserId = user?.uid else {
                Logger.log.show(details: "User does not exists", logType: .error).display(.toast)
                return
            }
            guard fromUserId != toUserId else {
                Logger.log.show(details: "Cannot send game invite to yourself", logType: .error).display(.toast)
                return
            }
            guard let lobbyId = self.lobbyId else {
                Logger.log.show(details: "lobby id not available", logType: .error)
                return
            }
            InviteManager.sendInvite(fromUserId: fromUserId, toUserId: toUserId, lobbyId: lobbyId)
        })
    }

    // MARK: Friend

    /// Send friend request to user with username
    /// - Parameter username: username of the receipient user
    func sendRequest(username: String) {
        guard let fromUserId = API.shared.user.currentUser?.uid else {
            Logger.log.show(details: "user is not logged in", logType: .error)
            return
        }
        API.shared.user.get(withUsername: username, completion: { user, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let toUserId = user?.uid else {
                Logger.log.show(details: "User does not exists", logType: .error).display(.toast)
                return
            }
            guard fromUserId != toUserId else {
                Logger.log.show(details: "Cannot send friend request to yourself", logType: .warning).display(.toast)
                return
            }
            RequestManager.sendRequest(fromUserId: fromUserId, toUserId: toUserId)
        })
    }

    /// Remove friend from friends list
    /// - Parameter username: username of the friend to be removed
    func removeFriend(username: String) {
        API.shared.user.get(withUsername: username, completion: { user, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let user = user else {
                return
            }
            API.shared.social.get(userId: user.uid, completion: { social, error in
                guard error == nil else {
                    Logger.log.show(details: error.debugDescription, logType: .error)
                    return
                }
                guard var social = social else {
                    return
                }
                guard let currentUser = API.shared.user.currentUser else {
                    return
                }
                self.social.removeFriend(userId: user.uid)
                API.shared.social.save(social: self.social)
                social.removeFriend(userId: currentUser.uid)
                API.shared.social.save(social: social)
            })
        })
    }
}
