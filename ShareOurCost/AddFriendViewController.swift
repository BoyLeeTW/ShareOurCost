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

        searchFriendUIDButton.addTarget(self, action: #selector(touchSearchFriendButton), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchSearchFriendButton() {

        guard let searchedUserUID = searchFriendUIDTextField.text else { return }

        friendManager.searchFriendNameByUserID(userID: searchedUserUID, completion: { (searchResult, searchedFriendUID, searchedUserName) in

            if searchResult == true {

                self.searchedFriendUID = searchedFriendUID!
                
                if searchedFriendUID == userUID {
                    
                    self.searchFriendUIDResultLabel.text = "Cannot add yourself lol"
                    
                } else {
                    
                    self.searchFriendUIDResultLabel.text = searchedUserName
                    
                }

            } else {

                self.searchFriendUIDResultLabel.text = "Not found!"

            }

        })

    }

//    func

}
