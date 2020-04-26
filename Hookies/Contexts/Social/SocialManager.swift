//
//  SocialManager.swift
//  Hookies
//
//  Created by Tan LongBin on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Social Manager handles all the social related calls to the API

struct SocialManager {

    /// Helper method to check if both sender and recipients exist
    /// - Parameters:
    ///   - fromUserId: User ID of sender
    ///   - toUserId: User ID of recipient
    ///   - completion: Returns true if both users exist, false otherwise
    static func checkUsersExist(fromUserId: String, toUserId: String, completion: @escaping (Bool) -> Void) {
        API.shared.user.get(withUid: fromUserId, completion: { sender, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return completion(false)
            }
            guard sender != nil else {
                Logger.log.show(details: "Sender of request not found", logType: .error)
                return completion(false)
            }
            API.shared.user.get(withUid: toUserId, completion: { recipient, error in
                guard error == nil else {
                    Logger.log.show(details: error.debugDescription, logType: .error)
                    return completion(false)
                }
                guard recipient != nil else {
                    Logger.log.show(details: "Recipient of request not found", logType: .error)
                    return completion(false)
                }
                return completion(true)
            })
        })
    }

    /// Helper method to check if the socials of both users exist
    /// - Parameters:
    ///   - fromUserId: User ID of sender
    ///   - toUserId: User ID of recipient
    ///   - completion: Returns true if both users' social exist, false otherwise
    static func checkUsersSocialExist(
        fromUserId: String,
        toUserId: String,
        completion: @escaping (Bool, Social?, Social?) -> Void
    ) {
        API.shared.social.get(userId: fromUserId, completion: { senderSocial, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return completion(false, nil, nil)
            }
            guard let senderSocial = senderSocial else {
                Logger.log.show(details: "Sender of request does not have social", logType: .error)
                return completion(false, nil, nil)
            }
            API.shared.social.get(userId: toUserId, completion: { recipientSocial, error in
                guard error == nil else {
                    Logger.log.show(details: error.debugDescription, logType: .error)
                    return completion(false, nil, nil)
                }
                guard let recipientSocial = recipientSocial else {
                    Logger.log.show(details: "Recipient of request does not have social", logType: .error)
                    return completion(false, nil, nil)
                }
                return completion(true, senderSocial, recipientSocial)
            })
        })
    }
}
