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

    @IBAction func touchSearchFriendButton(_ sender: Any) {

        let searchedUserID = phoneNumberTextField.text!

        var userID = String()

        var friendName = String()

        ref = Database.database().reference()

        ref.child("userID").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            userID = (dataSnapshot.value as? String)!

            if searchedUserID == userID {

                friendName = "It's you!"

                self.friendNameLabel.text = friendName

                self.addFriendButton.isEnabled = false

            } else {

                self.ref = Database.database().reference()

                self.ref.child("userID").queryOrderedByValue().queryEqual(toValue: searchedUserID).observeSingleEvent(of: .childAdded, with: { (dataSnapshot) in

                    self.addFriendID = dataSnapshot.key

                    self.ref.child("userInfo").child(dataSnapshot.key).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                        friendName = (dataSnapshot.value as? String)!

                        self.friendNameLabel.text = friendName

                        self.addFriendButton.isEnabled = true

                    })

                })

            }

        })

        friendName = "Not Found!"

        self.friendNameLabel.text = friendName

    }

    @IBAction func touchAddFriendButton(_ sender: Any) {

        if self.addFriendID != "" {

            ref = Database.database().reference()

            ref.child("userInfo").child(addFriendID).child("pendingFriendRequest").updateChildValues([(Auth.auth().currentUser?.uid)!: false])

            ref.child("userInfo").child((Auth.auth().currentUser?.uid)!).child("pendingSentFriendRequest").updateChildValues([addFriendID: false])

        }

    }

    var expenseList = [ExpenseModel]()

    var refExpense: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

//        successful test query function
//        ref.child("userInfo").child("N9dpyqGFCGXjtKXJh5fBwHHv7Zl1").child("friendList").queryOrderedByValue().queryEqual(toValue: true).observe(.childAdded, with: { (dataSnapshot) in
//
//            print(dataSnapshot)
//            print(dataSnapshot.key)
//            print(dataSnapshot.value)
//
//            for child in dataSnapshot.children {
//                print(child)
//            }
//        })

        logOutButton.addTarget(self, action: #selector(handleLouOut), for: .touchUpInside)

// MARK: retriving data from expense
//        refExpense = Database.database().reference().child("Expenses")
//        refExpense = Database.database().reference()

//        refExpense.observe(.value, with: { (dataSnapshot) in

//            guard let datas = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
//            print(datas)
//            for data in datas {
//                let dataObject = data.value as?[String: AnyObject]
//                let expenseDate = dataObjeㄩct!["Date"]!
//                let expenseAmount = dataObject!["Amount"]!
//                let expenseSharedMethod = dataObject!["SharedMethod"]!
//                let expenseSharedResult = dataObject!["SharedResult"]!
//                print(expenseAmount, expenseDate, expenseSharedMethod, expenseSharedResult)

//            }

//        })

    }

    func handleSearchFriend() {

    }

    func handleLouOut() {

        UserDefaults.standard.setValue(nil, forKey: "userUid")

        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")

        self.show(loginVC!, sender: nil)

    }
}
