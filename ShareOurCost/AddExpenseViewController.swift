//
//  AddExpenseViewController.swift
//  ShareOurCost
//
//  Created by Brad on 01/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddExpenseViewController: UIViewController {

    var ref: DatabaseReference!

    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseDescriptionTextField: UITextField!
    @IBOutlet weak var expenseDayTextField: UITextField!
    @IBOutlet weak var expenseSharedMemberTextField: UITextField!
    @IBOutlet weak var expenseSharedMethodTextField: UITextField!
    @IBAction func touchSaveExpenseButton(_ sender: Any) {

//        ref.database.reference().child("expenseList").childByAutoId().updateChildValues(["amount": "\(self.expenseAmountTextField.text!)",
//            "description": "\(self.expenseDescriptionTextField.text!)",
//            "expenseDay": "\(self.expenseDayTextField.text!)",
//            "SharedMember": "\(self.xpenseSharedMemberTextField.text!)",
//            "SharedMethod": "\(self.expenseSharedMethodTextField.text!)",
//            "createdTime": (Date().timeIntervalSince1970)
//            ])

    }


    override func viewDidLoad() {
        super.viewDidLoad()

//        ref = Database.database().reference().child(<#T##pathString: String##String#>)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

}
