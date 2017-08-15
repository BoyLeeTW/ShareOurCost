//
//  AddFriendViewController.swift
//  ShareOurCost
//
//  Created by Brad on 15/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {
    @IBOutlet weak var searchFriendUIDTextField: UITextField!
    @IBOutlet weak var searchFriendUIDButton: UIButton!
    @IBOutlet weak var searchFriendUIDResultLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!

    let friendManager = FriendManager()

    var searchedFriendUID = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addFriendButton.isHidden = true
        self.searchFriendUIDResultLabel.isHidden = true
        
        searchFriendUIDButton.addTarget(self, action: #selector(touchSearchFriendButton), for: .touchUpInside)

        addFriendButton.addTarget(self, action: #selector(touchAddFriend), for: .touchUpInside)

    }

    func touchSearchFriendButton() {

        searchedFriendUID = ""

        guard let searchedUserUID = searchFriendUIDTextField.text else { return }

        friendManager.searchFriendNameByUserID(userID: searchedUserUID, completion: { [weak self] (searchResult, searchedFriendUID, searchedUserName) in

            guard let weakSelf = self else { return }

            if searchResult == true {

                weakSelf.searchedFriendUID = searchedFriendUID!

                if searchedFriendUID == userUID {

                    weakSelf.searchFriendUIDResultLabel.text = "Cannot add yourself lol"
                    weakSelf.searchFriendUIDResultLabel.isHidden = false

                    weakSelf.addFriendButton.isHidden = true

                } else {
                    
                    weakSelf.searchFriendUIDResultLabel.text = searchedUserName
                    weakSelf.searchFriendUIDResultLabel.isHidden = false

                    weakSelf.addFriendButton.isHidden = false

                }

            } else {

                weakSelf.searchFriendUIDResultLabel.text = "Not found!"
                weakSelf.searchFriendUIDResultLabel.isHidden = false

                weakSelf.addFriendButton.isHidden = true

            }

        })

    }

    func touchAddFriend() {

        if self.searchedFriendUID != "" {

            friendManager.sendFriendRequest(friendUID: searchedFriendUID)

            let alertController = UIAlertController(title: "Success",
                                                    message: "Already sent your friend request!",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion:  nil)

        }

    }

}
