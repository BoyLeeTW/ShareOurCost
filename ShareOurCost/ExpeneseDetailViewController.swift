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
    @IBOutlet weak var expenseCreatedByLabel: UILabel!
    @IBOutlet weak var expenseCreatedDayLabel: UILabel!

    var ref: DatabaseReference!

    var allExpenseIDList = [String]()

    var selectedRow = Int()

    var expenseID = String()

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        setUpExpenseDetailLabel()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func setUpExpenseDetailLabel() {

        ref = Database.database().reference()
        
        ref.child("expenseList").child(expenseID).observe(.value, with: { (dataSnapshot) in

            guard let expenseData = dataSnapshot.value as? [String: Any],
                  let expenseTotalAmount = expenseData["amount"] as? Int,
                  let expenseCreatedBy = expenseData["createdBy"] as? String,
//                  let expenseCreatedDay = expenseData["createdTime"] as? Double,
                  let expenseCreatedDay = expenseData["createdTime"] as? String,
                  let expensePaidby = expenseData["expensePaidBy"] as? String,
                  let expenseDescription = expenseData["description"] as? String,
                  let expenseDay = expenseData["expenseDay"] as? String,
                  let sharedAmount = expenseData["sharedResult"] as? [String: Any],
                  let amountYouShared = sharedAmount["\(Auth.auth().currentUser!.uid)"] as? Int
            
                else { return }


            self.totalAmountLabel.text = "Total Amount: \(expenseTotalAmount)"
            self.expenseCreatedByLabel.text = "Created By: \(expenseCreatedBy)"
            self.expenseCreatedDayLabel.text = "Create Day: \(expenseCreatedDay)"
            self.expenseDescriptionLabel.text = "Description: \(expenseDescription)"
            self.amountYouSharedLabel.text = "Amount You Shared: \(amountYouShared)"
            self.expenseDateLabel.text = "\(expenseDay)"

        })

    }

}
