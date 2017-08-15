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

    var selectedRow = Int()

    var expenseID = String()

    var sharedFriendUID = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpExpenseDetailLabel()

        acceptExpenseButton.addTarget(self, action: #selector(touchAcceptButton), for: .touchUpInside)
        denyExpenseButton.addTarget(self, action: #selector(touchDenyButton), for: .touchUpInside)
        deleteExpenseButton.addTarget(self, action: #selector(touchDeleteButton), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
              let sharedAmount = expenseInformation["sharedResult"] as? [String: Any],
              let amountYouShared = sharedAmount["\(userUID)"] as? Int
        
            else { return }

        if friendUIDandNameList[expenseCreatedBy] == nil {

            expenseCreatedByName = "You"

        } else {

            expenseCreatedByName = friendUIDandNameList[expenseCreatedBy]!

        }

        self.totalAmountLabel.text = "Total Amount: \(expenseTotalAmount)"
        self.expenseCreatedByLabel.text = "Created By: \(expenseCreatedByName)"
        self.expenseCreatedDayLabel.text = "Create Day: \(expenseCreatedDay)"
        self.expenseDescriptionLabel.text = "Description: \(expenseDescription)"
        self.amountYouSharedLabel.text = "Amount You Shared: \(amountYouShared)"
        self.expenseDateLabel.text = "\(expenseDay)"

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
        
        expenseManager.changeExpenseStatus(friendUID: sharedFriendUID, expenseID: expenseID, changeSelfStatus: "sentDeleted", changeFriendStatus: "receivedDeleted")
        
    }

}
