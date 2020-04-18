//
//  InviteManager.swift
//  Hookies
//
//  Created by Tan LongBin on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct InviteManager {

    static func getInvites(inviteIds: [String], completion: @escaping ([Invite]) -> Void) {
        var invites: [Invite] = []
        let dispatch = DispatchGroup()
        for inviteId in inviteIds {
            dispatch.enter()
            API.shared.invite.get(inviteId: inviteId, completion: { invite, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                guard let invite = invite else {
                    return
                }
                invites.append(invite)
                dispatch.leave()
            })
        }
        dispatch.notify(queue: DispatchQueue.main) {
            completion(invites)
        }
    }

    static func checkRecipientIsNotInLobby(invite: Invite, completion: @escaping (Bool) -> Void) {
        API.shared.lobby.get(lobbyId: invite.lobbyId, completion: { lobby, error in
            guard error == nil else {
                print(error.debugDescription)
                return completion(false)
            }
            guard let lobby = lobby else {
                print("lobby not found")
                return completion(false)
            }
            guard !lobby.playersId.contains(invite.toUserId) else {
                print("Recipient is already in the lobby")
                return completion(false)
            }
            return completion(true)
        })
    }

    static func checkInviteIsNotRepeated(
        invite: Invite,
        sender: Social,
        recipient: Social,
        completion: @escaping (Bool) -> Void
    ) {
        self.getInvites(inviteIds: sender.outgoingInvites, completion: { invites in
            guard !invites.map({ $0.toUserId }).contains(invite.toUserId) else {
                print("invite to this player already exists")
                return completion(false)
            }
            self.getInvites(inviteIds: sender.incomingInvites, completion: { invites in
                guard !invites.map({ $0.fromUserId }).contains(invite.toUserId) else {
                    print("there is an existing invite from this player")
                    return completion(false)
                }
                self.getInvites(inviteIds: recipient.outgoingInvites, completion: { recipientInvites in
                    guard !recipientInvites.map({ $0.toUserId }).contains(invite.fromUserId) else {
                        print("there is an existing invite from this player")
                        return completion(false)
                    }
                    self.getInvites(inviteIds: recipient.incomingInvites, completion: { recipientInvites in
                        guard !recipientInvites.map({ $0.fromUserId }).contains(invite.fromUserId) else {
                            print("invite already exists")
                            return completion(false)
                        }
                        guard !invites.map({ $0.lobbyId }).contains(invite.lobbyId) else {
                            print("invite from this lobby id already exists")
                            return completion(false)
                        }
                        return completion(true)
                    })
                })
            })
        })
    }

    static func sendInvite(fromUserId: String, toUserId: String, lobbyId: String) {
        RequestManager.checkUsersExist(fromUserId: fromUserId, toUserId: toUserId) { usersExist in
            guard usersExist else {
                return
            }
            let invite = Invite(fromUserId: fromUserId, toUserId: toUserId, lobbyId: lobbyId)
            self.checkRecipientIsNotInLobby(invite: invite) { recipientIsNotInLobby in
                guard recipientIsNotInLobby else {
                    return
                }
                RequestManager.checkUsersSocialExist(
                    fromUserId: fromUserId,
                    toUserId: toUserId) { exists, sender, recipient  in
                        guard exists, var sender = sender, var recipient = recipient else {
                            return
                        }
                        self.checkInviteIsNotRepeated(
                            invite: invite,
                            sender: sender,
                            recipient: recipient
                        ) { notRepeated in
                            guard notRepeated else {
                                return
                            }
                            API.shared.invite.save(invite: invite)
                            sender.addOutgoingInvite(inviteId: invite.inviteId)
                            API.shared.social.save(social: sender)
                            recipient.addIncomingInvite(inviteId: invite.inviteId)
                            API.shared.social.save(social: recipient)
                        }
                }
            }
        }
    }

    static func getInvite(inviteId: String, completion: @escaping (Invite?) -> Void) {
        API.shared.invite.get(inviteId: inviteId, completion: { invite, error in
            guard error == nil else {
                print(error.debugDescription)
                return completion(nil)
            }
            guard let invite = invite else {
                print("invite not found")
                return completion(nil)
            }
            return completion(invite)
        })
    }

    static func processInvite(inviteId: String, completion: @escaping (Invite?) -> Void) {
        getInvite(inviteId: inviteId) { invite in
            guard let invite = invite else {
                return completion(nil)
            }
            RequestManager.checkUsersSocialExist(
                fromUserId: invite.fromUserId,
                toUserId: invite.toUserId
            ) { exists, sender, recipient  in
                guard exists else {
                    return completion(nil)
                }
                guard var sender = sender else {
                    return completion(nil)
                }
                guard var recipient = recipient else {
                    return completion(nil)
                }
                sender.removeInvite(inviteId: inviteId)
                API.shared.social.save(social: sender)
                recipient.removeInvite(inviteId: inviteId)
                API.shared.social.save(social: recipient)
                API.shared.invite.delete(invite: invite)
                completion(invite)
            }
        }
    }
}
