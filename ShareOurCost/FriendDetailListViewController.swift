//
//  FriendDetailListViewController.swift
//  ShareOurCost
//
//  Created by Brad on 15/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class FriendDetailListViewController: UIViewController {

    var friendUID = String()

    let expenseManager = ExpenseManager()

    var acceptedExpenseList = [String: [[String: Any]]]()

    var balanceToFriend = Int()

    var existingExpenseIDList = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        expenseManager.fetchAcceptedExpenseList { (acceptedExepnseList) in

            self.acceptedExpenseList = acceptedExepnseList

            guard let expenseInfoSource = acceptedExepnseList[self.friendUID] else { return }

            for expenseInfo in expenseInfoSource {

                guard let expenseDescription = expenseInfo["description"] as? String,
                    let sharedResult = expenseInfo["sharedResult"] as? [String: Int],
                    let isRead = expenseInfo["isRead"] as? Bool,
                    let expenseID = expenseInfo["id"] as? String,
                    let friendName = friendUIDandNameList[self.friendUID]
                
                    else { return }

                if self.existingExpenseIDList.contains(expenseID) {

                    continue

                } else {

                    self.existingExpenseIDList.append(expenseID)
                }

                for (key, value) in sharedResult where value < 0 {

                    //you own friend money
                    if key == userUID {

                        self.balanceToFriend += value

                    // friend owes you money
                    } else {

                        self.balanceToFriend -= value

                    }

                }

                if self.balanceToFriend < 0 {

                    print("You owe your friend $\(abs(self.balanceToFriend))")

                    
                } else {

                    print("Your friend owes you $\(abs(self.balanceToFriend))")

                }

            }

        }

    }

}
