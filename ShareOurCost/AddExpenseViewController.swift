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

class AddExpenseViewController: UIViewController {

    var ref: DatabaseReference!

    var friendList = [String: String]()

    var paidByResult = PaidBy.user

    var sharedMethod = SharedMethod.byNumber

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

        })

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFriendUIDToIDList()

        setUpDatePicker()

        setUpLayout()

        setUpButtons()

        userPercentLabel.isHidden = true
        friendPercentLabel.isHidden = true
        userSharedPercentTextField.isHidden = true
        friendSharedPercentTextField.isHidden = true

    }

    func setUpButtons() {

        paidByUserButton.addTarget(self, action: #selector(touchPaidByUser(_:)), for: .touchUpInside)
        
        paidByFriendButton.addTarget(self, action: #selector(touchPaidByFriend(_:)), for: .touchUpInside)
        
        shareExpenseEquallyButton.addTarget(self, action: #selector(touchShareExpenseEquallyButton), for: .touchUpInside)
        
        shareExpenseByPercentButton.addTarget(self, action: #selector(touchShareExpenseByPercentButton), for: .touchUpInside)
        
        expenseAmountTextField.addTarget(self, action: #selector(expenseAmountTextFieldChanged(_:)), for: .editingChanged)
        
        expenseSharedMemberTextField.addTarget(self, action: #selector(expenseSharedMamberTextFieldChanged(_:)), for: .editingChanged)
        
        userSharedAmountTextField.addTarget(self, action: #selector(userSharedAmountTextFieldChagned), for: .editingChanged)
        
        friendSharedAmountTextField.addTarget(self, action: #selector(friendSharedAmountTextFieldChagned), for: .editingChanged)
        
        userSharedPercentTextField.addTarget(self, action: #selector(userSharedPercentTextFieldChanged), for: .editingChanged)
        
        friendSharedPercentTextField.addTarget(self, action: #selector(friendSharedPercentTextFieldChanged), for: .editingChanged)

    }

    func setUpLayout() {

//        self.searchFriendUIDTextField.layer.borderWidth = 4
//        self.searchFriendUIDTextField.layer.borderColor = UIColor.white.cgColor
//        self.searchFriendUIDTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your friend's ID", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
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

    func fetchFriendUIDToIDList() {

        ref = Database.database().reference()

        ref.child("userInfo").child(userUID).child("friendList").observe(.childAdded, with: { (dataSnapshot) in

            let friendUID = dataSnapshot.key

                self.ref.child("userID").child(friendUID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

                    guard let userID = dataSnapshot.value as? String else { return }

                    self.ref.child("userInfo").child(friendUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                        guard let friendName = dataSnapshot.value as? String else { return }

                        self.friendList.updateValue(friendName, forKey: userID)

                    })

                })

        })

    }

    func expenseAmountTextFieldChanged(_ sender: UITextField) {
        guard let amountText = sender.text else { return }
        let amount: Double = Double(amountText) ?? 0

        userSharedAmountTextField.text = "\(Int(round(amount / 2)))"
        friendSharedAmountTextField.text = "\(Int(floor(amount / 2)))"

    }

    func expenseSharedMamberTextFieldChanged(_ sender: UITextField) {

        guard let enteredSharedMember = sender.text else { return }

        if let enteredFriendName = friendList[enteredSharedMember] {
                
            paidByFriendButton.setTitle(enteredFriendName, for: .normal)

        } else {

            self.paidByFriendButton.setTitle("Not Found!", for: .normal)

        }

    }

    func handleDatePicker(sender: UIDatePicker) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        expenseDayTextField.text = dateFormatter.string(from: sender.date)

    }

}
