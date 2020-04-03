//
//  RequestManager.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct RequestManager {
    static func checkUsersExist(fromUserId: String, toUserId: String, completion: @escaping (Bool) -> Void) {
        API.shared.user.get(withUid: fromUserId, completion: { sender, error in
            guard error == nil else {
                print(error.debugDescription)
                return completion(false)
            }
            guard sender != nil else {
                print("Sender of request not found")
                return completion(false)
            }
            API.shared.user.get(withUid: toUserId, completion: { recipient, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return completion(false)
                }
                guard recipient != nil else {
                    print("Recipient of request not found")
                    return completion(false)
                }
                return completion(true)
            })
        })
    }

    static func checkUsersSocialExist(request: Request, completion: @escaping (Bool, Social?, Social?) -> Void) {
        API.shared.social.get(userId: request.fromUserId, completion: { senderSocial, error in
            guard error == nil else {
                print(error.debugDescription)
                return completion(false, nil, nil)
            }
            guard let senderSocial = senderSocial else {
                print("Sender of request does not have social")
                return completion(false, nil, nil)
            }
            API.shared.social.get(userId: request.toUserId, completion: { recipientSocial, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return completion(false, nil, nil)
                }
                guard let recipientSocial = recipientSocial else {
                    print("Recipient of request does not have social")
                    return completion(false, nil, nil)
                }
                return completion(true, senderSocial, recipientSocial)
            })
        })
    }

    static func getRequests(requestIds: [String], completion: @escaping ([Request]) -> Void) {
        var requests: [Request] = []
        let dispatch = DispatchGroup()
        for requestId in requestIds {
            dispatch.enter()
            API.shared.request.get(requestId: requestId, completion: { request, error in
                guard error == nil else {
                    print(error.debugDescription)
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

    static func checkRequestIsNotRepeated(request: Request, sender: Social, recipient: Social, completion: @escaping (Bool) -> Void) {
        self.getRequests(requestIds: sender.outgoingRequests, completion: { requests in
            guard !requests.map({ $0.toUserId }).contains(request.toUserId) else {
                print("request already exists")
                return completion(false)
            }
            self.getRequests(requestIds: sender.incomingRequests, completion: { requests in
                guard !requests.map({ $0.fromUserId }).contains(request.toUserId) else {
                    print("request already exists")
                    return completion(false)
                }
                self.getRequests(requestIds: recipient.outgoingRequests, completion: { recipientRequests in
                    guard !recipientRequests.map({ $0.toUserId }).contains(request.fromUserId) else {
                        print("request already exists")
                        return completion(false)
                    }
                    self.getRequests(requestIds: recipient.incomingRequests, completion: { recipientRequests in
                        guard !recipientRequests.map({ $0.fromUserId }).contains(request.fromUserId) else {
                            print("request already exists")
                            return completion(false)
                        }
                        return completion(true)
                    })
                })
            })
        })
    }

    static func sendRequest(fromUserId: String, toUserId: String) {
        self.checkUsersExist(fromUserId: fromUserId, toUserId: toUserId, completion: { usersExist in
            guard usersExist else {
                return
            }
            let request = Request(fromUserId: fromUserId, toUserId: toUserId)
            self.checkUsersSocialExist(request: request, completion: { exists, senderSocial, recipientSocial  in
                guard exists else {
                    return
                }
                guard var sender = senderSocial else {
                    return
                }
                guard var recipient = recipientSocial else {
                    return
                }
                guard !sender.friends.contains(request.toUserId) && !recipient.friends.contains(request.fromUserId) else {
                    print("Users are already friends")
                    return
                }
                self.checkRequestIsNotRepeated(request: request, sender: sender, recipient: recipient, completion: { notRepeated in
                    guard notRepeated else {
                        return
                    }
                    API.shared.request.save(request: request)
                    sender.addOutgoingRequest(requestId: request.requestId)
                    API.shared.social.save(social: sender)
                    recipient.addIncomingRequest(requestId: request.requestId)
                    API.shared.social.save(social: recipient)
                })
            })
        })
    }

    static func getRequest(requestId: String, completion: @escaping (Request?) -> Void) {
        API.shared.request.get(requestId: requestId, completion: { request, error in
            guard error == nil else {
                print(error.debugDescription)
                return completion(nil)
            }
            guard let request = request else {
                print("request not found")
                return completion(nil)
            }
            return completion(request)
        })
    }

    static func acceptRequest(requestId: String) {
        getRequest(requestId: requestId, completion: { request in
            guard let request = request else {
                return
            }
            self.checkUsersSocialExist(request: request, completion: { exists, senderSocial, recipientSocial  in
                guard exists else {
                    return
                }
                guard var sender = senderSocial else {
                    return
                }
                guard var recipient = recipientSocial else {
                    return
                }
                sender.addFriend(userId: request.toUserId)
                sender.removeRequest(requestId: requestId)
                API.shared.social.save(social: sender)
                recipient.addFriend(userId: request.fromUserId)
                recipient.removeRequest(requestId: requestId)
                API.shared.social.save(social: recipient)
                API.shared.request.delete(request: request)
            })
        })
    }

    static func rejectRequest(requestId: String) {
        getRequest(requestId: requestId, completion: { request in
            guard let request = request else {
                return
            }
            self.checkUsersSocialExist(request: request, completion: { exists, senderSocial, recipientSocial  in
                guard exists else {
                    return
                }
                guard var sender = senderSocial else {
                    return
                }
                guard var recipient = recipientSocial else {
                    return
                }
                sender.removeRequest(requestId: requestId)
                API.shared.social.save(social: sender)
                recipient.removeRequest(requestId: requestId)
                API.shared.social.save(social: recipient)
                API.shared.request.delete(request: request)
            })
        })
    }
}
