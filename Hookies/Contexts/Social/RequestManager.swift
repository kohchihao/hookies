//
//  RequestManager.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Request Manager handles all request related calls to the API

struct RequestManager {

    /// Get requests using the request IDs
    /// - Parameters:
    ///   - requestIds: ID of requests to be retrieved
    ///   - completion: Returns an array of the retrieved requests if successful
    static func getRequests(requestIds: [String], completion: @escaping ([Request]) -> Void) {
        var requests: [Request] = []
        let dispatch = DispatchGroup()
        for requestId in requestIds {
            dispatch.enter()
            API.shared.request.get(requestId: requestId, completion: { request, error in
                guard error == nil else {
                    Logger.log.show(details: error.debugDescription, logType: .error)
                    return
                }
                guard let request = request else {
                    return
                }
                requests.append(request)
                dispatch.leave()
            })
        }
        dispatch.notify(queue: DispatchQueue.main) {
            completion(requests)
        }
    }

    /// Helper method to check that the request is not repeated
    /// - Parameters:
    ///   - request: Request to be checked
    ///   - sender: Social of the sender
    ///   - recipient: Social of the recipient
    ///   - completion: Returns true if the request is not repeated, false otherwise
    static func checkRequestIsNotRepeated(
        request: Request,
        sender: Social,
        recipient: Social,
        completion: @escaping (Bool) -> Void
    ) {
        self.getRequests(requestIds: sender.outgoingRequests, completion: { requests in
            guard !requests.map({ $0.toUserId }).contains(request.toUserId) else {
                Logger.log.show(details: "Request already exists", logType: .alert).display(.toast)
                return completion(false)
            }
            self.getRequests(requestIds: sender.incomingRequests, completion: { requests in
                guard !requests.map({ $0.fromUserId }).contains(request.toUserId) else {
                    Logger.log.show(details: "Request already exists", logType: .alert).display(.toast)
                    return completion(false)
                }
                self.getRequests(requestIds: recipient.outgoingRequests, completion: { recipientRequests in
                    guard !recipientRequests.map({ $0.toUserId }).contains(request.fromUserId) else {
                        Logger.log.show(details: "Request already exists", logType: .alert).display(.toast)
                        return completion(false)
                    }
                    self.getRequests(requestIds: recipient.incomingRequests, completion: { recipientRequests in
                        guard !recipientRequests.map({ $0.fromUserId }).contains(request.fromUserId) else {
                            Logger.log.show(details: "Request already exists", logType: .alert).display(.toast)
                            return completion(false)
                        }
                        return completion(true)
                    })
                })
            })
        })
    }

    /// Send friend request
    /// - Parameters:
    ///   - fromUserId: User ID of sender
    ///   - toUserId: User ID of recipient
    static func sendRequest(fromUserId: String, toUserId: String) {
        SocialManager.checkUsersExist(fromUserId: fromUserId, toUserId: toUserId) { usersExist in
            guard usersExist else {
                return
            }
            let request = Request(fromUserId: fromUserId, toUserId: toUserId)
            SocialManager.checkUsersSocialExist(
                fromUserId: fromUserId,
                toUserId: toUserId
            ) { exists, senderSocial, recipientSocial  in
                guard exists, var sender = senderSocial, var recipient = recipientSocial else {
                    return
                }
                guard !sender.friends.contains(request.toUserId)
                    && !recipient.friends.contains(request.fromUserId)
                    else {
                        Logger.log.show(details: "Users are already friends", logType: .alert).display(.toast)
                        return
                }
                self.checkRequestIsNotRepeated(request: request, sender: sender, recipient: recipient) { notRepeated in
                    guard notRepeated else {
                        return
                    }
                    API.shared.request.save(request: request)
                    sender.addOutgoingRequest(requestId: request.requestId)
                    API.shared.social.save(social: sender)
                    recipient.addIncomingRequest(requestId: request.requestId)
                    API.shared.social.save(social: recipient)
                }
            }
        }
    }

    /// Get request using request ID
    /// - Parameters:
    ///   - requestId: ID of the request to be retrieved
    ///   - completion: Returns the retrieved request if successful
    static func getRequest(requestId: String, completion: @escaping (Request?) -> Void) {
        API.shared.request.get(requestId: requestId, completion: { request, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return completion(nil)
            }
            guard let request = request else {
                Logger.log.show(details: "request not found", logType: .error)
                return completion(nil)
            }
            return completion(request)
        })
    }

    /// Accept a request
    /// - Parameter requestId: ID of the request to be accepted
    static func acceptRequest(requestId: String) {
        getRequest(requestId: requestId) { request in
            guard let request = request else {
                return
            }
            SocialManager.checkUsersSocialExist(
                fromUserId: request.fromUserId,
                toUserId: request.toUserId
            ) { exists, sender, recipient  in
                guard exists else {
                    return
                }
                guard var sender = sender else {
                    return
                }
                guard var recipient = recipient else {
                    return
                }
                sender.addFriend(userId: request.toUserId)
                sender.removeRequest(requestId: requestId)
                API.shared.social.save(social: sender)
                recipient.addFriend(userId: request.fromUserId)
                recipient.removeRequest(requestId: requestId)
                API.shared.social.save(social: recipient)
                API.shared.request.delete(request: request)
            }
        }
    }

    /// Reject the request
    /// - Parameter requestId: ID of the request to be rejected
    static func rejectRequest(requestId: String) {
        getRequest(requestId: requestId) { request in
            guard let request = request else {
                return
            }
            SocialManager.checkUsersSocialExist(
                fromUserId: request.fromUserId,
                toUserId: request.toUserId
            ) { exists, sender, recipient  in
                guard exists else {
                    return
                }
                guard var sender = sender else {
                    return
                }
                guard var recipient = recipient else {
                    return
                }
                sender.removeRequest(requestId: requestId)
                API.shared.social.save(social: sender)
                recipient.removeRequest(requestId: requestId)
                API.shared.social.save(social: recipient)
                API.shared.request.delete(request: request)
            }
        }
    }
}
