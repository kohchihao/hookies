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
    @IBOutlet private var requestTableView: UITableView!
    @IBOutlet private var inviteTableView: UITableView!
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
        socialTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")

        requestTableView.dataSource = self
        requestTableView.delegate = self
        requestTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")

        inviteTableView.dataSource = self
        inviteTableView.delegate = self
        inviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
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
        guard let toUserId = requestTextField.text else {
            return
        }
        guard !toUserId.isEmpty else {
            print("user Id field cannot be empty")
            return
        }
        guard let fromUserId = API.shared.user.currentUser?.uid else {
            print("user is not logged in")
            return
        }
        API.shared.user.get(withUid: toUserId, completion: { user, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard user != nil else {
                print("Recipient of request not found")
                return
            }
            let request = Request(fromUserId: fromUserId, toUserId: toUserId)
            API.shared.social.get(userId: toUserId, completion: { social, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                guard var social = social else {
                    print("Recipient of request does not have social")
                    return
                }
                API.shared.request.save(request: request)
                self.viewModel.social.addRequest(requestId: request.requestId)
                self.saveSocial(social: self.viewModel.social)
                social.addRequest(requestId: request.requestId)
                self.saveSocial(social: social)
            })
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
            })
        })
    }

    func updateView() {
        self.socialLabel.text = self.viewModel.social.userId
        self.socialTableView.reloadData()
        self.requestTableView.reloadData()
        self.inviteTableView.reloadData()
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
        case self.requestTableView:
            return self.viewModel.social.requests.count
        case self.inviteTableView:
            return self.viewModel.social.invites.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        switch tableView {
        case self.socialTableView:
            getUsername(userId: self.viewModel.social.friends[indexPath.row], cell: cell)
        case self.requestTableView:
            cell.textLabel?.text = self.viewModel.social.requests[indexPath.row]
        case self.inviteTableView:
            cell.textLabel?.text = self.viewModel.social.invites[indexPath.row]
        default:
            return cell
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        mapDelegate?.onSelected(for: )
        switch tableView {
        case self.socialTableView:
            print(self.viewModel.social.friends[indexPath.row])
        case self.requestTableView:
            acceptRequest(requestId: self.viewModel.social.requests[indexPath.row])
        case self.inviteTableView:
            print(self.viewModel.social.invites[indexPath.row])
        default:
            break
        }
        self.dismiss(animated: false, completion: nil)
    }}
