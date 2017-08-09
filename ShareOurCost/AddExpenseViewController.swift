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

class AddExpenseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var ref: DatabaseReference!

    var cellStatus = "left"

    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseDescriptionTextField: UITextField!
    @IBOutlet weak var expenseDayTextField: UITextField!
    @IBOutlet weak var expenseSharedMemberTextField: UITextField!
    @IBOutlet weak var expenseSharedMethodTextField: UITextField!
    @IBOutlet weak var expensePaidByTestField: UITextField!
    @IBOutlet weak var sharedResultCollectionView: UICollectionView!
    @IBAction func reloadCollectionView(_ sender: Any) {

        print(sharedResultCollectionView)


    }
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

            self.ref.database.reference().child("userExpense").child(Auth.auth().currentUser!.uid).updateChildValues([expenseID: "sentPending"])

            self.ref.database.reference().child("userExpense").child(friendUID).updateChildValues([expenseID: "receivedPending"])

            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MM"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH"
            let minuteFormatter = DateFormatter()
            minuteFormatter.dateFormat = "mm"
            
            expenseRef.updateChildValues(
                ["amount": Int(self.expenseAmountTextField.text!)!,
                "description": "\(self.expenseDescriptionTextField.text!)",
                "expenseDay": "\(self.expenseDayTextField.text!)",
                "sharedMember": "\(self.expenseSharedMemberTextField.text!)",
                "sharedMethod": "\(self.expenseSharedMethodTextField.text!)",
                "expensePaidBy": "\(self.expensePaidByTestField.text!)",
                "createdTime": (String(describing: Date())),
                "createdBy": "\(Auth.auth().currentUser!.uid)",
                "sharedWith": "\(friendUID)",
                "sharedResult": ["\(Auth.auth().currentUser!.uid)": sharedAmountForUser, "\(friendUID)": sharedAmountForFriend]
                ]
            )

            self.expenseSharedMemberTextField.text = ""
            self.expensePaidByTestField.text = ""
            self.expenseDayTextField.text = ""
            self.expenseAmountTextField.text = ""
            self.expenseDescriptionTextField.text = ""
            self.expenseSharedMethodTextField.text = ""

        })

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let datePicker = UIDatePicker()

        datePicker.datePickerMode = .date

        expenseDayTextField.inputView = datePicker

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy/MM/dd"

        expenseDayTextField.text = dateFormatter.string(from: Date())

        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

    }

    func handleDatePicker(sender: UIDatePicker) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        expenseDayTextField.text = dateFormatter.string(from: sender.date)

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedRseultCell", for: indexPath) as! ExpenseSharedResultCollectionViewCell

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if self.cellStatus == "left" {
            self.cellStatus = "right"
            print("it's right now")
        } else {
            self.cellStatus = "left"
            print("it's left now")
        }

    }

}
