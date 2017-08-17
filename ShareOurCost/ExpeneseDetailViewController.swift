//
//  ExpeneseDetailViewController.swift
//  ShareOurCost
//
//  Created by Brad on 06/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class ExpeneseDetailViewController: UIViewController {

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountYouSharedLabel: UILabel!
    @IBOutlet weak var expenseDateLabel: UILabel!
    @IBOutlet weak var expenseDescriptionLabel: UILabel!
    @IBOutlet weak var expenseCreatedByLabel: UILabel!
    @IBOutlet weak var expenseCreatedDayLabel: UILabel!
    @IBOutlet weak var acceptExpenseButton: UIButton!
    @IBOutlet weak var denyExpenseButton: UIButton!
    @IBOutlet weak var deleteExpenseButton: UIButton!

    var allExpenseIDList = [String]()

    var expenseInformation = [String: Any]()

    var expenseID = String()

    var sharedFriendUID = String()

    var expenseStatus = String()

    var isAcceptButtonHidden = Bool()

    var isDenyButtonHidden = Bool()

    var isDeleteButtonHidden = Bool()

    let expenseManager = ExpenseManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpExpenseDetailLabel()

        setUpButton()

        acceptExpenseButton.addTarget(self, action: #selector(touchAcceptButton), for: .touchUpInside)
        denyExpenseButton.addTarget(self, action: #selector(touchDenyButton), for: .touchUpInside)
        deleteExpenseButton.addTarget(self, action: #selector(touchDeleteButton), for: .touchUpInside)

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func setUpExpenseDetailLabel() {

        var expenseCreatedByName = String()

        guard let expenseTotalAmount = expenseInformation["amount"] as? Int,
              let expenseCreatedBy = expenseInformation["createdBy"] as? String,
              let expenseCreatedDay = expenseInformation["createdTime"] as? String,
              let expensePaidBy = expenseInformation["expensePaidBy"] as? String,
              let expenseDescription = expenseInformation["description"] as? String,
              let expenseDay = expenseInformation["expenseDay"] as? String,
              let expenseID = expenseInformation["id"] as? String,
              let expenseSahreWith = expenseInformation["sharedWith"] as? String,
              let sharedAmount = expenseInformation["sharedResult"] as? [String: Any],
              let amountYouShared = sharedAmount["\(userUID)"] as? Int
        
            else { return }

        self.expenseID = expenseID

        if expenseCreatedBy == userUID {
            
            self.sharedFriendUID = expenseSahreWith
            
        } else {
            
            
            self.sharedFriendUID = expenseCreatedBy
            
        }

        if friendUIDandNameList[expenseCreatedBy] == nil {

            expenseCreatedByName = "You"

        } else {

            expenseCreatedByName = friendUIDandNameList[expenseCreatedBy]!

        }

        self.totalAmountLabel.text = "Total Amount: $\(expenseTotalAmount)"
        self.expenseCreatedByLabel.text = "Created By: \(expenseCreatedByName)"
        self.expenseCreatedDayLabel.text = "Create Day: \(expenseCreatedDay)"
        self.expenseDescriptionLabel.text = "Description: \(expenseDescription)"
        self.amountYouSharedLabel.text = "Amount You Shared: $\(abs(amountYouShared))"
        self.expenseDateLabel.text = "\(expenseDay)"

    }

    func setUpButton() {

        acceptExpenseButton.isHidden = isAcceptButtonHidden

        denyExpenseButton.isHidden = isDenyButtonHidden

        deleteExpenseButton.isHidden = isDeleteButtonHidden

    }

    func touchAcceptButton() {

        guard let expenseCreatedBy = expenseInformation["createdBy"] as? String,
            let expenseSahreWith = expenseInformation["sharedWith"] as? String,
            let expenseID = expenseInformation["id"] as? String
            else { return }
        
        if expenseCreatedBy == userUID {
            
            sharedFriendUID = expenseSahreWith
            
        } else {
            
            sharedFriendUID = expenseCreatedBy
            
        }

        let expenseManager = ExpenseManager()

        expenseManager.changeExpenseStatus(friendUID: sharedFriendUID, expenseID: expenseID, changeSelfStatus: "accepted", changeFriendStatus: nil)

    }

    func touchDenyButton() {

        guard let expenseCreatedBy = expenseInformation["createdBy"] as? String,
            let expenseSahreWith = expenseInformation["sharedWith"] as? String,
            let expenseID = expenseInformation["id"] as? String
            else { return }

        if expenseCreatedBy == userUID {

            sharedFriendUID = expenseSahreWith

        } else {

            sharedFriendUID = expenseCreatedBy

        }

        let expenseManager = ExpenseManager()

        expenseManager.changeExpenseStatus(friendUID: sharedFriendUID, expenseID: expenseID, changeSelfStatus: "denied", changeFriendStatus: nil)

    }

    func touchDeleteButton() {

        let alertController = UIAlertController(title: "Attention",
                                                message: "Do you really want to delete?",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { _ in

            if self.expenseStatus == "sentPending" || self.expenseStatus == "denied" || self.expenseStatus == "receivedDeleted" {

                self.navigationController?.popViewController(animated: true)

                self.expenseManager.deleteExpense(friendUID: self.sharedFriendUID, expenseID: self.expenseID)

            } else {

                let alertController = UIAlertController(title: "Success",
                                                        message: "This expense will be deleted after your friend approve it",
                                                        preferredStyle: .alert)
                let notificationAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    
                    print("sent delete invitation!")
                    self.navigationController?.popViewController(animated: true)

                    self.expenseManager.changeExpenseStatus(friendUID: self.sharedFriendUID, expenseID: self.expenseID, changeSelfStatus: "sentDeleted", changeFriendStatus: "receivedDeleted")
                    
                    self.expenseManager.changeExpenseReadStatus(friendUID: self.sharedFriendUID, expenseID: self.expenseID, changeSelfStatus: true, changeFriendStatus: false)


                })

                alertController.addAction(notificationAction)
                self.present(alertController, animated: true, completion:  nil)

            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion:  nil)

    }

}
