//
//  AddExpenseViewController.swift
//  ShareOurCost
//
//  Created by Brad on 01/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddExpenseViewController: UIViewController {

    var ref: DatabaseReference!

    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseDescriptionTextField: UITextField!
    @IBOutlet weak var expenseDayTextField: UITextField!
    @IBOutlet weak var expenseSharedMemberTextField: UITextField!
    @IBOutlet weak var expenseSharedMethodTextField: UITextField!
    @IBOutlet weak var expensePaidByTestField: UITextField!
    @IBAction func touchSaveExpenseButton(_ sender: Any) {

        ref = Database.database().reference()

        var friendUID = String()

        let friendIDText = expenseSharedMemberTextField.text!

        ref.child("userID").queryOrderedByValue().queryEqual(toValue: friendIDText).observeSingleEvent(of: .childAdded, with: { (dataSnapshot) in
            friendUID = dataSnapshot.key

            let expenseRef = self.ref.child("expenseList").childByAutoId()

            let expenseID = expenseRef.key

            var sharedAmountForUser = Double()

            var sharedAmountForFriend = Double()

            if self.expensePaidByTestField.text! == "Y" {

                sharedAmountForUser = Double(self.expenseAmountTextField.text!)!/2

                sharedAmountForFriend = -Double(self.expenseAmountTextField.text!)!/2

            } else {

                sharedAmountForUser = -Double(self.expenseAmountTextField.text!)!/2
                
                sharedAmountForFriend = Double(self.expenseAmountTextField.text!)!/2

            }

            self.ref.database.reference().child("userExpense").child(Auth.auth().currentUser!.uid).updateChildValues([expenseID: "pending"])

            self.ref.database.reference().child("userExpense").child(friendUID).updateChildValues([expenseID: "pending"])

            expenseRef.updateChildValues(
                ["amount": Int(self.expenseAmountTextField.text!)!,
                "description": "\(self.expenseDescriptionTextField.text!)",
                "expenseDay": "\(self.expenseDayTextField.text!)",
                "sharedMember": "\(self.expenseSharedMemberTextField.text!)",
                "sharedMethod": "\(self.expenseSharedMethodTextField.text!)",
                "expensePaidBy": "\(self.expensePaidByTestField.text!)",
                "createdTime": (Date().timeIntervalSince1970),
                "createdBy": "\(Auth.auth().currentUser!.uid)",
                "sahredWith": "\(friendUID)",
                "sharedResult": ["\(Auth.auth().currentUser!.uid)": sharedAmountForUser, "\(friendUID)": sharedAmountForFriend]
                ]
            )

            self.expenseSharedMemberTextField.text = ""
            self.expensePaidByTestField.text = ""
            self.expenseDayTextField.text = ""
            self.expenseAmountTextField.text = ""
            self.expenseDescriptionTextField.text = ""
            self.expenseSharedMethodTextField.text = ""

            self.dismiss(animated: true, completion: nil)
        })

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

}
