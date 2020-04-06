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
    func didAcceptInvite(invite: Invite)
}

class SocialViewController: UIViewController {
    weak var navigationDelegate: SocialViewNavigationDelegate?
    private var viewModel: SocialViewModelRepresentable
    private var uid = RandomIDGenerator.getRandomID(length: 4)

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

        var identifier = "FriendTableViewCell"

        socialTableView.dataSource = self
        socialTableView.delegate = self
        let friendTableViewCell = UINib(nibName: identifier, bundle: nil)
        socialTableView.register(friendTableViewCell, forCellReuseIdentifier: identifier)
        socialTableView.allowsSelection = false

        identifier = "IncomingTableViewCell"
        incomingRequestTableView.dataSource = self
        incomingRequestTableView.delegate = self
        incomingRequestTableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        incomingRequestTableView.allowsSelection = false

        identifier = "OutgoingTableViewCell"
        outgoingRequestTableView.dataSource = self
        outgoingRequestTableView.delegate = self
        outgoingRequestTableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        outgoingRequestTableView.allowsSelection = false

        identifier = "IncomingTableViewCell"
        incomingInviteTableView.dataSource = self
        incomingInviteTableView.delegate = self
        incomingInviteTableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)

        identifier = "OutgoingTableViewCell"
        outgoingInviteTableView.dataSource = self
        outgoingInviteTableView.delegate = self
        outgoingInviteTableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)

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
                API.shared.social.save(social: self.viewModel.social)
                return
            }
            self.viewModel.social = social
            API.shared.social.save(social: self.viewModel.social)
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
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

    func updateUsernameInCell(userId: String, cell: UITableViewCell) {
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
            guard fromUserId != toUserId else {
                print("cannot send friend request to yourself")
                return
            }
            RequestManager.sendRequest(fromUserId: fromUserId, toUserId: toUserId)
        })
    }

    func updateRequestInCell(requestId: String, cell: UITableViewCell) {
        RequestManager.getRequest(requestId: requestId, completion: { request in
            guard let request = request else {
                return
            }
            switch cell {
            case let cell as IncomingTableViewCell:
                cell.request = request
                cell.invite = nil
                self.updateUsernameInCell(userId: request.fromUserId, cell: cell)
                return
            case let cell as OutgoingTableViewCell:
                cell.request = request
                cell.invite = nil
                self.updateUsernameInCell(userId: request.toUserId, cell: cell)
                return
            default:
                return
            }
        })
    }

    func updateInviteInCell(inviteId: String, cell: UITableViewCell) {
        InviteManager.getInvite(inviteId: inviteId, completion: { invite in
            guard let invite = invite else {
                return
            }
            switch cell {
            case let cell as IncomingTableViewCell:
                cell.invite = invite
                cell.request = nil
                self.updateUsernameInCell(userId: invite.fromUserId, cell: cell)
                return
            case let cell as OutgoingTableViewCell:
                cell.invite = invite
                cell.request = nil
                self.updateUsernameInCell(userId: invite.toUserId, cell: cell)
                return
            default:
                return
            }
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
            API.shared.social.save(social: self.viewModel.social)
            social.removeFriend(userId: currentUser.uid)
            API.shared.social.save(social: social)
        })
    }

    func updateView() {
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
            updateUsernameInCell(userId: self.viewModel.social.friends[indexPath.row], cell: cell)
            if self.viewModel.inviteEnabled {
                cell.showInviteButton()
            } else {
                cell.hideInviteButton()
            }
            return cell
        case self.incomingRequestTableView:
            let identifier = "IncomingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? IncomingTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            updateRequestInCell(requestId: self.viewModel.social.incomingRequests[indexPath.row], cell: cell)
            return cell
        case self.outgoingRequestTableView:
            let identifier = "OutgoingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OutgoingTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            updateRequestInCell(requestId: self.viewModel.social.outgoingRequests[indexPath.row], cell: cell)
            return cell
        case self.incomingInviteTableView:
            let identifier = "IncomingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? IncomingTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            updateInviteInCell(inviteId: self.viewModel.social.incomingInvites[indexPath.row], cell: cell)
            return cell
        case self.outgoingInviteTableView:
            let identifier = "OutgoingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? OutgoingTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            updateInviteInCell(inviteId: self.viewModel.social.outgoingInvites[indexPath.row], cell: cell)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       switch tableView {
       case self.socialTableView:
           return "Friends"
       case self.incomingRequestTableView:
           return "Incoming Requests"
       case self.outgoingRequestTableView:
           return "Outgoing Requests"
       case self.incomingInviteTableView:
           return "Incoming Game Invites"
       case self.outgoingInviteTableView:
           return "Outgoing Game Invites"
       default:
           return ""
       }
    }
}

extension SocialViewController: FriendTableViewCellDelegate {
    func inviteButtonPressed(username: String) {
        guard self.viewModel.inviteEnabled else {
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
            guard fromUserId != toUserId else {
                print("cannot send game invite to yourself")
                return
            }
            guard let lobbyId = self.viewModel.lobbyId else {
                print("lobby id not available")
                return
            }
            InviteManager.sendInvite(fromUserId: fromUserId, toUserId: toUserId, lobbyId: lobbyId)
        })
    }

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

extension SocialViewController: IncomingTableViewCellDelegate {
    func acceptButtonPressed(requestId: String) {
        RequestManager.acceptRequest(requestId: requestId)
    }

    func rejectButtonPressed(requestId: String) {
        RequestManager.rejectRequest(requestId: requestId)
    }

    func acceptButtonPressed(inviteId: String) {
        guard self.viewModel.lobbyId == nil else {
            print("you cannot accept a game invite when you are in the pre-game lobby")
            return
        }
        InviteManager.processInvite(inviteId: inviteId, completion: { invite in
            guard let invite = invite else {
                return
            }
            self.navigationDelegate?.didAcceptInvite(invite: invite)
            self.dismiss(animated: false, completion: nil)
        })
    }

    func rejectButtonPressed(inviteId: String) {
        InviteManager.processInvite(inviteId: inviteId, completion: {_ in })
    }
}

extension SocialViewController: OutgoingTableViewCellDelegate {
    func cancelButtonPressed(requestId: String) {
        RequestManager.rejectRequest(requestId: requestId)
    }

    func cancelButtonPressed(inviteId: String) {
        InviteManager.processInvite(inviteId: inviteId, completion: {_ in })
    }
}
