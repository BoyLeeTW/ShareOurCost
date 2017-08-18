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

enum PaidBy {

    case user

    case friend

}

enum SharedMethod {

    case byNumber

    case byPercent
}


class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var ref: DatabaseReference!

    var friendList = [String: String]()

    var paidByResult = PaidBy.user

    var sharedMethod = SharedMethod.byNumber

    let friendNamePickerView = UIPickerView()

    let friendManager = FriendManager()

    var friendNameList = [String]()

    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseDescriptionTextField: UITextField!
    @IBOutlet weak var expenseDayTextField: UITextField!
    @IBOutlet weak var expenseSharedMemberTextField: UITextField!
    @IBOutlet weak var paidByUserButton: UIButton!
    @IBOutlet weak var paidByFriendButton: UIButton!
    @IBOutlet weak var userSharedAmountTextField: UITextField!
    @IBOutlet weak var friendSharedAmountTextField: UITextField!
    @IBOutlet weak var shareExpenseEquallyButton: UIButton!
    @IBOutlet weak var shareExpenseByPercentButton: UIButton!
    @IBOutlet weak var userSharedPercentTextField: UITextField!
    @IBOutlet weak var friendSharedPercentTextField: UITextField!
    @IBOutlet weak var userPercentLabel: UILabel!
    @IBOutlet weak var friendPercentLabel: UILabel!
    @IBOutlet weak var biggestView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        friendManager.fetchFriendNameAndUIDList(completion: {

            self.setUpFriendNamePicker()

            let alertController = UIAlertController(title: "Oops",
                                                    message: "Please add friend so you can share cost with them",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",
                                              style: .cancel,
                                              handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: {
                
                self.navigationController?.popViewController(animated: true)
                
            })

        })

        setUpDatePicker()

        setUpLayout()

        setUpButtons()

        userPercentLabel.isHidden = true
        friendPercentLabel.isHidden = true
        userSharedPercentTextField.isHidden = true
        friendSharedPercentTextField.isHidden = true

    }

    @IBAction func touchSaveExpenseButton(_ sender: Any) {

        ref = Database.database().reference()

        let friendNameText = expenseSharedMemberTextField.text!

        guard let friendUID = friendNameAndUIDList[friendNameText] else { return }

        let expenseRef = self.ref.child("expenseList").childByAutoId()

        let expenseID = expenseRef.key

        var sharedAmountForUser = Double()

        var sharedAmountForFriend = Double()

        var paidBy = ""

        if self.sharedMethod == .byNumber {

            if self.paidByResult == .user {
                    
                sharedAmountForUser = Double(self.userSharedAmountTextField.text!)!
                    
                sharedAmountForFriend = -Double(self.friendSharedAmountTextField.text!)!
                    
                paidBy = userUID
                    
            } else {
                    
                sharedAmountForUser = -Double(self.userSharedAmountTextField.text!)!
                    
                sharedAmountForFriend = Double(self.friendSharedAmountTextField.text!)!

                paidBy = friendUID
                    
            }

            } else {

                guard let sharedPercentAmountForUserText = self.userSharedPercentTextField.text,
                      let totalExepnseAmountText = self.expenseAmountTextField.text
                    else { return }
                let sharedPercentAmountForUser = Double(sharedPercentAmountForUserText) ?? 0
                let totalExpenseAmount = Double(totalExepnseAmountText) ?? 0
                
                if self.paidByResult == .user {
                    
                    sharedAmountForUser = round(Double(sharedPercentAmountForUser * totalExpenseAmount / 100))
                    
                    sharedAmountForFriend = -floor(Double((100 - sharedPercentAmountForUser) * totalExpenseAmount / 100))
                    
                    paidBy = userUID
                    
                } else {
                    
                    sharedAmountForUser = -round(Double(sharedPercentAmountForUser * totalExpenseAmount / 100))
                    
                    sharedAmountForFriend = floor(Double((100 - sharedPercentAmountForUser) * totalExpenseAmount / 100))
                    
                    paidBy = friendUID
                    
                }

            }

            self.ref.database.reference().child("userExpense").child(userUID).child(expenseID).updateChildValues(["status": "sentPending", "isRead": true])

            self.ref.database.reference().child("userExpense").child(friendUID).child(expenseID).updateChildValues(["status": "receivedPending", "isRead": false])

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            expenseRef.updateChildValues(
                ["amount": Int(self.expenseAmountTextField.text!)!,
                "description": "\(self.expenseDescriptionTextField.text!)",
                "expenseDay": "\(self.expenseDayTextField.text!)",
                "sharedMember": "\(self.expenseSharedMemberTextField.text!)",
                "expensePaidBy": "\(paidBy)",
                "createdTime": (dateFormatter.string(from: Date())),
                "createdBy": "\(userUID)",
                "sharedWith": "\(friendUID)",
                "sharedResult": ["\(userUID)": Int(sharedAmountForUser), "\(friendUID)": Int(sharedAmountForFriend)]
                ]
            )

            self.expenseSharedMemberTextField.text = ""
            self.expenseDayTextField.text = ""
            self.expenseAmountTextField.text = ""
            self.expenseDescriptionTextField.text = ""

            self.navigationController?.popViewController(animated: true)

    }

    func setUpFriendNamePicker() {

        for (name, _) in friendNameAndUIDList {

            if friendNameList.contains(name) {

                continue

            } else {

                friendNameList.append(name)

            }

        }

        friendNamePickerView.delegate = self
        expenseSharedMemberTextField.inputView = friendNamePickerView
        if friendNameList.count > 0 {

            expenseSharedMemberTextField.text = friendNameList[0]

        }

    }

    func setUpButtons() {

        paidByUserButton.addTarget(self, action: #selector(touchPaidByUser(_:)), for: .touchUpInside)
        
        paidByFriendButton.addTarget(self, action: #selector(touchPaidByFriend(_:)), for: .touchUpInside)
        
        shareExpenseEquallyButton.addTarget(self, action: #selector(touchShareExpenseEquallyButton), for: .touchUpInside)
        
        shareExpenseByPercentButton.addTarget(self, action: #selector(touchShareExpenseByPercentButton), for: .touchUpInside)
        
        expenseAmountTextField.addTarget(self, action: #selector(expenseAmountTextFieldChanged(_:)), for: .editingChanged)

        userSharedAmountTextField.addTarget(self, action: #selector(userSharedAmountTextFieldChagned), for: .editingChanged)
        
        friendSharedAmountTextField.addTarget(self, action: #selector(friendSharedAmountTextFieldChagned), for: .editingChanged)
        
        userSharedPercentTextField.addTarget(self, action: #selector(userSharedPercentTextFieldChanged), for: .editingChanged)
        
        friendSharedPercentTextField.addTarget(self, action: #selector(friendSharedPercentTextFieldChanged), for: .editingChanged)

    }

    func setUpLayout() {

        self.biggestView.layer.borderWidth = 4
        self.biggestView.layer.borderColor = UIColor.white.cgColor

        self.expenseDayTextField.layer.borderWidth = 3
        self.expenseDayTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseDayTextField.attributedPlaceholder = NSAttributedString(string: "Date", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseSharedMemberTextField.layer.borderWidth = 3
        self.expenseSharedMemberTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseSharedMemberTextField.attributedPlaceholder = NSAttributedString(string: "Shared friend", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseAmountTextField.layer.borderWidth = 3
        self.expenseAmountTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseAmountTextField.attributedPlaceholder = NSAttributedString(string: "Shared amount", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseDescriptionTextField.layer.borderWidth = 3
        self.expenseDescriptionTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseDescriptionTextField.attributedPlaceholder = NSAttributedString(string: "Description", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_navigate_before_white_36pt"), style: .plain, target: self, action: #selector(touchBackButton))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        self.navigationItem.title = "Add Expense"

    }

    func touchBackButton() {

        self.navigationController?.popViewController(animated: true)

    }

    func touchShareExpenseEquallyButton() {

        guard let totalAmountText = expenseAmountTextField.text else { return }
        let totalAmount: Double = Double(totalAmountText) ?? 0
        
        userSharedAmountTextField.text = "\(Int(round(totalAmount / 2)))"
        friendSharedAmountTextField.text = "\(Int(floor(totalAmount / 2)))"

        shareExpenseEquallyButton.backgroundColor = UIColor.red
        shareExpenseEquallyButton.setTitleColor(UIColor.white, for: .normal)
        
        shareExpenseByPercentButton.backgroundColor = UIColor.clear
        shareExpenseByPercentButton.setTitleColor(UIColor.blue, for: .normal)

        userPercentLabel.isHidden = true
        friendPercentLabel.isHidden = true
        userSharedPercentTextField.isHidden = true
        friendSharedPercentTextField.isHidden = true
        userSharedAmountTextField.isHidden = false
        friendSharedAmountTextField.isHidden = false

        sharedMethod = SharedMethod.byNumber

    }

    func touchShareExpenseByPercentButton() {
        
        userSharedPercentTextField.text = "50"
        friendSharedPercentTextField.text = "50"

        userPercentLabel.isHidden = false
        friendPercentLabel.isHidden = false
        userSharedPercentTextField.isHidden = false
        friendSharedPercentTextField.isHidden = false
        userSharedAmountTextField.isHidden = true
        friendSharedAmountTextField.isHidden = true
        
        shareExpenseEquallyButton.backgroundColor = UIColor.clear
        shareExpenseEquallyButton.setTitleColor(UIColor.blue, for: .normal)
        
        shareExpenseByPercentButton.backgroundColor = UIColor.red
        shareExpenseByPercentButton.setTitleColor(UIColor.white, for: .normal)

        sharedMethod = SharedMethod.byPercent

    }

    func userSharedPercentTextFieldChanged() {

        guard let userSharedPercentText = userSharedPercentTextField.text else { return }

        let userSharedPercent = Int(userSharedPercentText) ?? 0
        friendSharedPercentTextField.text = "\(100 - userSharedPercent)"
        
    }

    func friendSharedPercentTextFieldChanged() {

        guard let friendSharedPercentText = friendSharedPercentTextField.text else { return }
        
        let friendSharedPercent = Int(friendSharedPercentText) ?? 0
        userSharedPercentTextField.text = "\(100 - friendSharedPercent)"

    }

    func userSharedAmountTextFieldChagned() {

        guard let totalAmountText = expenseAmountTextField.text,
              let userSharedAmountText = userSharedAmountTextField.text
        
            else { return }

        let totalAmount = Int(totalAmountText) ?? 0,
            userSharedAmount = Int(userSharedAmountText) ?? 0

        friendSharedAmountTextField.text = "\((totalAmount - userSharedAmount))"

    }

    func friendSharedAmountTextFieldChagned() {

        guard let totalAmountText = expenseAmountTextField.text,
            let friendSharedAmountText = friendSharedAmountTextField.text
            
            else { return }
        
        let totalAmount = Int(totalAmountText) ?? 0,
        friendSharedAmount = Int(friendSharedAmountText) ?? 0
        
        userSharedAmountTextField.text = "\((totalAmount - friendSharedAmount))"

    }

    func touchPaidByUser(_ sender: UIButton) {

        paidByResult = PaidBy.user

        paidByUserButton.backgroundColor = UIColor.red
        paidByUserButton.setTitleColor(UIColor.white, for: .normal)
        
        paidByFriendButton.backgroundColor = UIColor.clear
        paidByFriendButton.setTitleColor(UIColor.blue, for: .normal)

    }

    func touchPaidByFriend(_ sender: UIButton) {

        paidByResult = PaidBy.friend

        paidByUserButton.backgroundColor = UIColor.clear
        paidByUserButton.setTitleColor(UIColor.blue, for: .normal)

        
        paidByFriendButton.backgroundColor = UIColor.red
        paidByFriendButton.setTitleColor(UIColor.white, for: .normal)

    }

    func setUpDatePicker() {

        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        
        expenseDayTextField.inputView = datePicker
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        expenseDayTextField.text = dateFormatter.string(from: Date())
        
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

    }

    func expenseAmountTextFieldChanged(_ sender: UITextField) {
        guard let amountText = sender.text else { return }
        let amount: Double = Double(amountText) ?? 0

        userSharedAmountTextField.text = "\(Int(round(amount / 2)))"
        friendSharedAmountTextField.text = "\(Int(floor(amount / 2)))"

    }

    func handleDatePicker(sender: UIDatePicker) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        expenseDayTextField.text = dateFormatter.string(from: sender.date)

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1

    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return friendNameList.count

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return friendNameList[row]

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        expenseSharedMemberTextField.text = friendNameList[row]
        paidByFriendButton.setTitle(friendNameList[row], for: .normal)

        self.view.endEditing(true)
    }

}
