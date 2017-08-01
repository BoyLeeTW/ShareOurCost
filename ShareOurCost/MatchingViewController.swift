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

        let phoneNumber = phoneNumberTextField.text!

        ref = Database.database().reference()

        ref.child("userID").observe(.childAdded, with: { (dataSnapshot) in
            // 之後改成用ID配對
            if let databasePhoneNumber = dataSnapshot.value as? String {

                if databasePhoneNumber == phoneNumber {

                    self.ref.child("userInfo").child(dataSnapshot.key).child("fullName").observe(.value, with: { (dataSnapshot) in

                        self.friendNameLabel.text = dataSnapshot.value as? String
                    })

                    //save corresponding userID
                    self.addFriendID = dataSnapshot.key

                } else {

                    self.friendNameLabel.text = "Not Found!"

                }

            }

        })

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

//        var ref: DatabaseReference!
//
//        let array = ["0": "A", "1": "B"]
//
//        ref.database.reference().childByAutoId().setValue(array)

        logOutButton.addTarget(self, action: #selector(handleLouOut), for: .touchUpInside)

// MARK: retriving data from expense
//        refExpense = Database.database().reference().child("Expenses")
        refExpense = Database.database().reference()

        refExpense.observe(.value, with: { (dataSnapshot) in

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

        })

    }

    func handleSearchFriend() {

    }

    func handleLouOut() {

        UserDefaults.standard.setValue(nil, forKey: "userUid")

        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")

        self.show(loginVC!, sender: nil)

    }
}
