//
//  SocialViewController.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

protocol SocialViewNavigationDelegate: class {

}

class SocialViewController: UIViewController {
    weak var navigationDelegate: SocialViewNavigationDelegate?
    private var viewModel: SocialViewModelRepresentable

    @IBOutlet private var socialLabel: UILabel!
    @IBOutlet private var socialTableView: UITableView!
    @IBOutlet private var incomingRequestTableView: UITableView!
    @IBOutlet private var outgoingRequestTableView: UITableView!
    @IBOutlet private var incomingInviteTableView: UITableView!
    @IBOutlet private var outgoingInviteTableView: UITableView!
    @IBOutlet private var requestTextField: UITextField!

    init(with viewModel: SocialViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: SocialViewController.name, bundle: nil)
        updateViewModel()
        subscribeToSocial(social: viewModel.social)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        socialTableView.dataSource = self
        socialTableView.delegate = self
        let friendTableViewCell = UINib(nibName: "FriendTableViewCell", bundle: nil)
        socialTableView.register(friendTableViewCell, forCellReuseIdentifier: "FriendTableViewCell")
        socialTableView.allowsSelection = false

        incomingRequestTableView.dataSource = self
        incomingRequestTableView.delegate = self
        let requestTableViewCell = UINib(nibName: "RequestTableViewCell", bundle: nil)
        incomingRequestTableView.register(requestTableViewCell, forCellReuseIdentifier: "RequestTableViewCell")
        incomingRequestTableView.allowsSelection = false

        outgoingRequestTableView.dataSource = self
        outgoingRequestTableView.delegate = self
        outgoingRequestTableView.register(requestTableViewCell, forCellReuseIdentifier: "RequestTableViewCell")
        outgoingRequestTableView.allowsSelection = false

        incomingInviteTableView.dataSource = self
        incomingInviteTableView.delegate = self
        incomingInviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")

        outgoingInviteTableView.dataSource = self
        outgoingInviteTableView.delegate = self
        outgoingInviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")

        updateView()
    }

    func updateViewModel() {
        guard let currentUser = API.shared.user.currentUser else {
            fatalError("User is not logged in")
        }
        API.shared.social.get(userId: currentUser.uid, completion: { social, error in
            guard error == nil else {
                return
            }
            guard let social = social else {
                self.viewModel = SocialViewModel()
                API.shared.social.save(social: self.viewModel.social)
                return
            }
            self.viewModel = SocialViewModel(social: social)
            API.shared.social.save(social: social)
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func saveSocial(social: Social) {
        API.shared.social.save(social: social)
    }

    func subscribeToSocial(social: Social) {
        guard let currentUser = API.shared.user.currentUser else {
            return
        }
        API.shared.social.subscribeToSocial(userId: currentUser.uid, listener: { social, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let updatedSocial = social else {
                return
            }
            self.viewModel.social = updatedSocial
            self.updateView()
        })
    }

    func getUsername(userId: String, cell: UITableViewCell) {
        API.shared.user.get(withUid: userId, completion: { user, error in
            guard error == nil else {
                return
            }
            guard let user = user else {
                return
            }
            cell.textLabel?.text = user.username
        })
    }

    @IBAction private func sendRequestButtonClicked(_ sender: UIButton) {
        guard let username = requestTextField.text else {
            return
        }
        guard !username.isEmpty else {
            print("username field cannot be empty")
            return
        }
        guard let fromUserId = API.shared.user.currentUser?.uid else {
            print("user is not logged in")
            return
        }
        API.shared.user.get(withUsername: username, completion: { user, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let toUserId = user?.uid else {
                print("user does not exists")
                return
            }
            guard !self.viewModel.social.friends.contains(toUserId) else {
                print("Recipient is already in friend list")
                return
            }
            RequestManager.sendRequest(fromUserId: fromUserId, toUserId: toUserId)
        })
    }

    func acceptRequest(requestId: String) {
        guard let currentUser = API.shared.user.currentUser else {
            return
        }
        API.shared.request.get(requestId: requestId, completion: { request, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let request = request else {
                print("request not found")
                return
            }
            guard request.fromUserId != currentUser.uid && request.toUserId == currentUser.uid else {
                print("request is invalid")
                return
            }
            API.shared.social.get(userId: request.fromUserId, completion: { social, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                guard var social = social else {
                    print("Sender of request not found")
                    return
                }
                social.addFriend(userId: request.toUserId)
                social.removeRequest(requestId: requestId)
                self.saveSocial(social: social)
                self.viewModel.social.addFriend(userId: request.fromUserId)
                self.viewModel.social.removeRequest(requestId: requestId)
                self.saveSocial(social: self.viewModel.social)
                API.shared.request.delete(request: request)
            })
        })
    }

    func rejectRequest(requestId: String) {
        API.shared.request.get(requestId: requestId, completion: { request, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let request = request else {
                print("request not found")
                return
            }
            API.shared.social.get(userId: request.fromUserId, completion: { social, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                guard var social = social else {
                    print("Sender of request not found")
                    return
                }
                social.removeRequest(requestId: requestId)
                self.saveSocial(social: social)
                self.viewModel.social.removeRequest(requestId: requestId)
                self.saveSocial(social: self.viewModel.social)
                API.shared.request.delete(request: request)
            })
        })
    }

    func getRecipientName(requestId: String, cell: RequestTableViewCell) {
        API.shared.request.get(requestId: requestId, completion: { request, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let request = request else {
                return
            }
            cell.request = request
            self.getUsername(userId: request.toUserId, cell: cell)
        })
    }

    func removeFriend(user: User) {
        API.shared.social.get(userId: user.uid, completion: { social, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard var social = social else {
                return
            }
            guard let currentUser = API.shared.user.currentUser else {
                return
            }
            self.viewModel.social.removeFriend(userId: user.uid)
            self.saveSocial(social: self.viewModel.social)
            social.removeFriend(userId: currentUser.uid)
            self.saveSocial(social: social)
        })
    }

    func updateView() {
        self.socialLabel.text = self.viewModel.social.userId
        self.socialTableView.reloadData()
        self.incomingRequestTableView.reloadData()
        self.outgoingRequestTableView.reloadData()
        self.incomingInviteTableView.reloadData()
        self.outgoingInviteTableView.reloadData()
    }

    deinit {
        API.shared.social.unsubscribeFromSocial()
    }
}

extension SocialViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.socialTableView:
            return self.viewModel.social.friends.count
        case self.incomingRequestTableView:
            return self.viewModel.social.incomingRequests.count
        case self.outgoingRequestTableView:
            return self.viewModel.social.outgoingRequests.count
        case self.incomingInviteTableView:
            return self.viewModel.social.incomingInvites.count
        case self.outgoingInviteTableView:
            return self.viewModel.social.outgoingInvites.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.socialTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            getUsername(userId: self.viewModel.social.friends[indexPath.row], cell: cell)
            return cell
        case self.incomingRequestTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestTableViewCell", for: indexPath) as? RequestTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            getRecipientName(requestId: self.viewModel.social.incomingRequests[indexPath.row], cell: cell)
            return cell
        case self.outgoingRequestTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestTableViewCell", for: indexPath) as? RequestTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            getRecipientName(requestId: self.viewModel.social.outgoingRequests[indexPath.row], cell: cell)
            return cell
        case self.incomingInviteTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            cell.textLabel?.text = self.viewModel.social.incomingInvites[indexPath.row]
            return cell
        case self.outgoingInviteTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            cell.textLabel?.text = self.viewModel.social.outgoingInvites[indexPath.row]
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch tableView {
//        case self.socialTableView:
//            print(self.viewModel.social.friends[indexPath.row])
//        case self.requestTableView:
//            acceptRequest(requestId: self.viewModel.social.requests[indexPath.row])
//        case self.inviteTableView:
//            print(self.viewModel.social.invites[indexPath.row])
//        default:
//            break
//        }
//        self.dismiss(animated: false, completion: nil)
//    }
}

extension SocialViewController: FriendTableViewCellDelegate {
    func deleteButtonPressed(username: String) {
        API.shared.user.get(withUsername: username, completion: { user, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let user = user else {
                return
            }
            self.removeFriend(user: user)
        })
    }
}

extension SocialViewController: RequestTableViewCellDelegate {
    func acceptButtonPressed(requestId: String) {
        acceptRequest(requestId: requestId)
    }

    func rejectButtonPressed(requestId: String) {
        rejectRequest(requestId: requestId)
    }
}
