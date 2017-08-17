 //
//  MatchingViewController.swift
//  ShareOurCost
//
//  Created by Brad on 26/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MatchingViewController: UIViewController {
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var searchFriendButton: UIButton!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!

    var ref: DatabaseReference!

    var addFriendID = String()

    var friendManager = FriendManager()

    @IBAction func touchSearchFriendButton(_ sender: Any) {

        let searchedUserID = phoneNumberTextField.text!

        friendManager.checkFriendID(userID: searchedUserID, completion: { (userSelfID, searchResult, searchedUID) in

            if searchResult == true {

                if userSelfID == searchedUserID {

                    self.friendNameLabel.text = "It's you!"

                } else {

                    self.friendManager.fetchUserInformation(searchedUID: searchedUID, completion: { (userName) in

                        self.friendNameLabel.text = userName

                        self.addFriendID = searchedUID

                    })

                }

            } else {

               self.friendNameLabel.text = "Not Found!"

            }

        })

    }

    @IBAction func touchAddFriendButton(_ sender: Any) {

        if self.addFriendID != "" {

            ref = Database.database().reference()

            ref.child("userInfo").child(addFriendID).child("pendingFriendRequest").updateChildValues([(Auth.auth().currentUser?.uid)!: false])

            ref.child("userInfo").child(userUID).child("pendingSentFriendRequest").updateChildValues([addFriendID: false])

        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logOutButton.addTarget(self, action: #selector(handleLouOut), for: .touchUpInside)

    }
    
    func handleLouOut() {

        UserDefaults.standard.setValue(nil, forKey: "userUid")

        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")

        self.show(loginVC!, sender: nil)

    }
}
 
