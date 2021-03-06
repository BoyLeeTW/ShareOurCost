//
//  ExpeneseDetailViewController.swift
//  ShareOurCost
//
//  Created by Brad on 06/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase

class ExpeneseDetailViewController: UIViewController {

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountYouSharedLabel: UILabel!
    @IBOutlet weak var expenseDateLabel: UILabel!
    @IBOutlet weak var expenseDescriptionLabel: UILabel!
    @IBOutlet weak var expensePaidByLabel: UILabel!
    @IBOutlet weak var expenseCreatedDayLabel: UILabel!
    @IBOutlet weak var acceptExpenseButton: UIButton!
    @IBOutlet weak var denyExpenseButton: UIButton!
    @IBOutlet weak var deleteExpenseButton: UIButton!
    @IBOutlet weak var biggestView: UIView!

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

        setUpViews()

        setUpNavigationBar()

        setUpGesture()

    }

    func setUpNavigationBar() {

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_white"), style: .plain,
                                                                target: self,
                                                                action: #selector(touchBackButton))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        self.navigationController?.navigationBar.topItem?.title = "EXPENSE DETAIL"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18.0)!]

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func setUpViews() {

        biggestView.layer.borderWidth = 4
        biggestView.layer.borderColor = UIColor.white.cgColor

    }

    func setUpExpenseDetailLabel() {

        var expenseCreatedByName = String()

        var expensePaidByName = String()
        
        guard
            let expenseTotalAmount = expenseInformation["amount"] as? Int,
            let expenseCreatedBy = expenseInformation["createdBy"] as? String,
            let expenseCreatedDay = expenseInformation["createdTime"] as? String,
            let expenseDescription = expenseInformation["description"] as? String,
            let expenseDay = expenseInformation["expenseDay"] as? String,
            let expenseID = expenseInformation["id"] as? String,
            let expenseShareWith = expenseInformation["sharedWith"] as? String,
            let sharedAmount = expenseInformation["sharedResult"] as? [String: Any],
            let amountYouShared = sharedAmount["\(userUID)"] as? Int
            else { return }

        self.expenseID = expenseID

        if expenseCreatedBy == userUID {

            self.sharedFriendUID = expenseShareWith

        } else {

            self.sharedFriendUID = expenseCreatedBy

        }

        if friendUIDandNameList[expenseCreatedBy] == nil {
            
            expensePaidByName = "You"
            
        } else {

            guard let expensePaidByNameString = friendUIDandNameList[expenseCreatedBy]
                else { return }

            expensePaidByName = expensePaidByNameString
            
        }

        if friendUIDandNameList[expenseCreatedBy] == nil {

            expenseCreatedByName = "You"

        } else {

            guard let expenseCreatedByNameString = friendUIDandNameList[expenseCreatedBy]
                else { return }

            expenseCreatedByName = expenseCreatedByNameString

        }

        self.totalAmountLabel.text = "TOTAL Amount: $" + "\(expenseTotalAmount)".currencyInputFormatting()
        self.expensePaidByLabel.text = "PAID BY: \(expensePaidByName)"
        self.expenseCreatedDayLabel.text = "Added by \(expenseCreatedByName) on \(expenseCreatedDay)"
        self.expenseDescriptionLabel.text = "DESCRIPTION: \(expenseDescription)"
        self.amountYouSharedLabel.text = "AMOUNT YOU SHARED: $" + "\(abs(amountYouShared))".currencyInputFormatting()
        self.expenseDateLabel.text = "EXPENSE DAY: \(expenseDay)"

    }

    func setUpButton() {

        acceptExpenseButton.isHidden = isAcceptButtonHidden
        denyExpenseButton.isHidden = isDenyButtonHidden
        deleteExpenseButton.isHidden = isDeleteButtonHidden

        acceptExpenseButton.addTarget(self, action: #selector(touchAcceptButton), for: .touchUpInside)
        denyExpenseButton.addTarget(self, action: #selector(touchDenyButton), for: .touchUpInside)
        deleteExpenseButton.addTarget(self, action: #selector(touchDeleteButton), for: .touchUpInside)

    }

    func touchAcceptButton() {

        Analytics.logEvent("clickAcceptExpenseButton", parameters: nil)

        guard
            let expenseCreatedBy = expenseInformation["createdBy"] as? String,
            let expenseShareWith = expenseInformation["sharedWith"] as? String,
            let expenseID = expenseInformation["id"] as? String
            else { return }

        if expenseCreatedBy == userUID {

            sharedFriendUID = expenseShareWith

        } else {

            sharedFriendUID = expenseCreatedBy

        }

        let expenseManager = ExpenseManager()

        expenseManager.changeExpenseStatus(friendUID: sharedFriendUID,
                                           expenseID: expenseID,
                                           changeSelfStatus: "accepted",
                                           changeFriendStatus: nil)

        expenseManager.changeExpenseReadStatus(friendUID: self.sharedFriendUID,
                                               expenseID: self.expenseID,
                                               changeSelfStatus: true,
                                               changeFriendStatus: false)

        self.dismiss(animated: true, completion: nil)

    }

    func touchDenyButton() {

        Analytics.logEvent("clickDenyExpenseButton", parameters: nil)

        guard
            let expenseCreatedBy = expenseInformation["createdBy"] as? String,
            let expenseSahreWith = expenseInformation["sharedWith"] as? String,
            let expenseID = expenseInformation["id"] as? String
            else { return }

        if expenseCreatedBy == userUID {

            sharedFriendUID = expenseSahreWith

        } else {

            sharedFriendUID = expenseCreatedBy

        }

        let expenseManager = ExpenseManager()

        if expenseStatus == "receivedDeleted" {

            expenseManager.changeExpenseStatus(friendUID: sharedFriendUID,
                                               expenseID: expenseID,
                                               changeSelfStatus: "accepted",
                                               changeFriendStatus: nil)

            expenseManager.changeExpenseReadStatus(friendUID: self.sharedFriendUID,
                                                   expenseID: self.expenseID,
                                                   changeSelfStatus: true,
                                                   changeFriendStatus: false)

            self.dismiss(animated: true, completion: nil)

        } else {

            expenseManager.changeExpenseStatus(friendUID: sharedFriendUID,
                                               expenseID: expenseID,
                                               changeSelfStatus: "sentDenied",
                                               changeFriendStatus: "denied")

            expenseManager.changeExpenseReadStatus(friendUID: self.sharedFriendUID,
                                                   expenseID: self.expenseID,
                                                   changeSelfStatus: true,
                                                   changeFriendStatus: false)

            self.dismiss(animated: true, completion: nil)

        }

    }

    func touchDeleteButton() {

        Analytics.logEvent("clickDeleteExpenseButton", parameters: nil)

        let alertController = UIAlertController(title: "Attention",
                                                message: "Do you really want to delete?",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { _ in

            if self.expenseStatus == "sentPending" || self.expenseStatus == "denied" || self.expenseStatus == "receivedDeleted" {

                self.dismiss(animated: true, completion: nil)

                Analytics.logEvent("clickDeleteExpenseButtonAndDeleteDirectly", parameters: nil)

                self.expenseManager.deleteExpense(friendUID: self.sharedFriendUID, expenseID: self.expenseID)

            } else {

                let alertController = UIAlertController(title: "Success",
                                                        message: "This expense will be deleted after your friend approve it",
                                                        preferredStyle: .alert)
                let notificationAction = UIAlertAction(title: "OK", style: .default, handler: { _ in

                    Analytics.logEvent("clickDeleteExpenseButtonAndDeletePending", parameters: nil)

                    self.dismiss(animated: true, completion: nil)

                    self.expenseManager.changeExpenseStatus(friendUID: self.sharedFriendUID,
                                                            expenseID: self.expenseID,
                                                            changeSelfStatus: "sentDeleted",
                                                            changeFriendStatus: "receivedDeleted")

                    self.expenseManager.changeExpenseReadStatus(friendUID: self.sharedFriendUID,
                                                                expenseID: self.expenseID,
                                                                changeSelfStatus: true,
                                                                changeFriendStatus: false)

                })

                alertController.addAction(notificationAction)
                self.present(alertController, animated: true, completion:  nil)

            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func setUpGesture() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .down
        self.view.addGestureRecognizer(swipeRight)
        
    }

    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
            self.dismiss(animated: true, completion: nil)

        }
    }
}
