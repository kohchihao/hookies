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

    @IBOutlet private var socialTableView: UITableView!
    @IBOutlet private var incomingRequestTableView: UITableView!
    @IBOutlet private var outgoingRequestTableView: UITableView!
    @IBOutlet private var incomingInviteTableView: UITableView!
    @IBOutlet private var outgoingInviteTableView: UITableView!
    @IBOutlet private var requestTextField: UITextField!

    init(with viewModel: SocialViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: SocialViewController.name, bundle: nil)
        self.viewModel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var identifier = "FriendTableViewCell"
        setUpTableView(tableView: socialTableView, identifier: identifier)

        identifier = "IncomingTableViewCell"
        setUpTableView(tableView: incomingRequestTableView, identifier: identifier)
        setUpTableView(tableView: incomingInviteTableView, identifier: identifier)

        identifier = "OutgoingTableViewCell"
        setUpTableView(tableView: outgoingInviteTableView, identifier: identifier)
        setUpTableView(tableView: outgoingRequestTableView, identifier: identifier)

        viewModel.subscribeToSocial()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.unsubscribeSocial()
    }

    private func setUpTableView(tableView: UITableView, identifier: String) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        tableView.allowsSelection = false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction private func sendRequestButtonClicked(_ sender: UIButton) {
        guard let username = requestTextField.text else {
            return
        }
        guard !username.isEmpty else {
            Logger.log.show(details: "Username field cannot be empty", logType: .warning).display(.toast)
            return
        }
        viewModel.sendRequest(username: username)
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
}

extension SocialViewController: SocialViewModelDelegate {
    func updateView() {
        self.socialTableView.reloadData()
        self.incomingRequestTableView.reloadData()
        self.outgoingRequestTableView.reloadData()
        self.incomingInviteTableView.reloadData()
        self.outgoingInviteTableView.reloadData()
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FriendTableViewCell",
                for: indexPath) as? FriendTableViewCell
                else {
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath) as? IncomingTableViewCell
                else {
                    return UITableViewCell()
            }
            cell.delegate = self
            updateRequestInCell(requestId: self.viewModel.social.incomingRequests[indexPath.row], cell: cell)
            return cell
        case self.outgoingRequestTableView:
            let identifier = "OutgoingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath) as? OutgoingTableViewCell
                else {
                    return UITableViewCell()
            }
            cell.delegate = self
            updateRequestInCell(requestId: self.viewModel.social.outgoingRequests[indexPath.row], cell: cell)
            return cell
        case self.incomingInviteTableView:
            let identifier = "IncomingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath) as? IncomingTableViewCell
                else {
                    return UITableViewCell()
            }
            cell.delegate = self
            updateInviteInCell(inviteId: self.viewModel.social.incomingInvites[indexPath.row], cell: cell)
            return cell
        case self.outgoingInviteTableView:
            let identifier = "OutgoingTableViewCell"
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath) as? OutgoingTableViewCell
                else {
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
        viewModel.sendInvite(username: username)
    }

    func deleteButtonPressed(username: String) {
        viewModel.removeFriend(username: username)
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
            Logger.log.show(
                details: "You cannot accept a game invite when you are in the pre-game lobby",
                logType: .warning).display(.toast)
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
        InviteManager.processInvite(inviteId: inviteId, completion: { _ in })
    }
}

extension SocialViewController: OutgoingTableViewCellDelegate {
    func cancelButtonPressed(requestId: String) {
        RequestManager.rejectRequest(requestId: requestId)
    }

    func cancelButtonPressed(inviteId: String) {
        InviteManager.processInvite(inviteId: inviteId, completion: { _ in })
    }
}
