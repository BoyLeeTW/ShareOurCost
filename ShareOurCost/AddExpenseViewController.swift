//
//  AddExpenseViewController.swift
//  ShareOurCost
//
//  Created by Brad on 01/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    enum PaidBy {
        
        case user
        case friend
        
    }
    
    enum SharedMethod {
        
        case byNumber
        case byPercent
        
    }

    var ref: DatabaseReference!

    var friendList = [String: String]()

    var paidByResult = PaidBy.user

    var sharedMethod = SharedMethod.byNumber

    let friendNamePickerView = UIPickerView()

    let friendManager = FriendManager()

    var friendNameList = [String]()

    var isTouchShareMemberTextFieldFirstTime: Bool = true

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
    @IBOutlet weak var friendSharesLabel: UILabel!
    @IBOutlet weak var biggestView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()

        setUpGesture()

        fetchFriendUIDAndNameListThenSetUpTableView()

        setUpDatePicker()

        setUpLayout()

        setUpButtons()

        setUpTextFieldTarget()

        setUpNavigationBar(withTitle: "ADD EXPENSE", presentedOrPushed: .pushed)

    }

    @IBAction func touchSaveExpenseButton(_ sender: Any) {

        Analytics.logEvent("clickSaveExpenseButton", parameters: nil)

        if expenseAmountTextField.text == "" || userSharedAmountTextField.text == "" || friendSharedAmountTextField.text == "" || expenseDescriptionTextField.text == "" {

            Analytics.logEvent("clickSaveExpenseButtonWithoutAllInformation", parameters: nil)

            let alertController = UIAlertController(title: "Oops!", message: "Please fill in all information!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

            return

        }

        Analytics.logEvent("saveExpenseSuccessfully", parameters: nil)

        ref = Database.database().reference()

        let friendNameText = expenseSharedMemberTextField.text!

        guard let friendUID = friendNameAndUIDList[friendNameText]
            else { return }

        let expenseRef = self.ref.child("expenseList").childByAutoId()

        let expenseID = expenseRef.key

        var sharedAmountForUser = Double()

        var sharedAmountForFriend = Double()

        var paidBy = ""

        if self.sharedMethod == .byNumber {

            if self.paidByResult == .user {

                sharedAmountForUser = Double(self.userSharedAmountTextField.text!.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))!

                sharedAmountForFriend = -Double(self.friendSharedAmountTextField.text!.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))!

                paidBy = userUID

            } else {

                sharedAmountForUser = -Double(self.userSharedAmountTextField.text!.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))!

                sharedAmountForFriend = Double(self.friendSharedAmountTextField.text!.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))!

                paidBy = friendUID

            }

        } else {

            guard
                let sharedPercentAmountForUserText = self.userSharedPercentTextField.text,
                let totalExepnseAmountText = self.expenseAmountTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
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
            ["amount": Int(self.expenseAmountTextField.text!.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))!,
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

        self.navigationController?.popViewController(animated: true)

    }

    func fetchFriendUIDAndNameListThenSetUpTableView() {

        if friendUIDList.count == 0 {

            friendManager.fetchFriendUIDList (completion: { [weak self] (friendUIDListOfBlock) in

                guard let weakSelf = self
                    else { return }

                friendUIDList = friendUIDListOfBlock

                weakSelf.friendManager.fetchFriendNameAndUIDList(completion: {

                    weakSelf.setUpFriendNamePicker()

                })

            })

        } else {

            friendManager.fetchFriendNameAndUIDList(completion: {

                self.setUpFriendNamePicker()

            })

        }
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

    }

    func touchSharedMemberText() {

        if friendNameList.count == 0 {

            self.expenseSharedMemberTextField.deleteBackward()

            let alertController = UIAlertController(title: "Oops!",
                                                    message: "Please add friend so you can share cost with them",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: {

                self.navigationController?.popViewController(animated: true)

            })

        } else {

            if isTouchShareMemberTextFieldFirstTime {

                self.isTouchShareMemberTextFieldFirstTime = false

                expenseSharedMemberTextField.text = friendNameList[0]

                if friendNameList[0].characters.count > 7 {

                    friendSharesLabel.text = "FRIEND\nSHARES"
                    paidByFriendButton.setTitle("FRIEND", for: .normal)

                } else {

                    friendSharesLabel.text = "\(friendNameList[0])\nSHARES"
                    paidByFriendButton.setTitle(friendNameList[0], for: .normal)

                }

            }

        }

    }

    func setUpButtons() {

        paidByUserButton.addTarget(self, action: #selector(touchPaidByUser(_:)), for: .touchUpInside)
        paidByUserButton.layer.borderWidth = 2
        paidByUserButton.layer.borderColor = UIColor.white.cgColor

        paidByFriendButton.addTarget(self, action: #selector(touchPaidByFriend(_:)), for: .touchUpInside)
        paidByFriendButton.layer.borderWidth = 2
        paidByFriendButton.layer.borderColor = UIColor.white.cgColor

        shareExpenseEquallyButton.addTarget(self, action: #selector(touchShareExpenseEquallyButton), for: .touchUpInside)
        shareExpenseEquallyButton.layer.borderWidth = 2
        shareExpenseEquallyButton.layer.borderColor = UIColor.white.cgColor

        shareExpenseByPercentButton.addTarget(self, action: #selector(touchShareExpenseByPercentButton), for: .touchUpInside)
        shareExpenseByPercentButton.layer.borderWidth = 2
        shareExpenseByPercentButton.layer.borderColor = UIColor.white.cgColor

    }

    func setUpTextFieldTarget() {

        expenseAmountTextField.addTarget(self, action: #selector(expenseAmountTextFieldChanged(_:)), for: .editingChanged)

        expenseSharedMemberTextField.addTarget(self, action: #selector(touchSharedMemberText), for: .editingDidBegin)

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
        self.expenseDayTextField.attributedPlaceholder = NSAttributedString(string: "DATE", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseSharedMemberTextField.layer.borderWidth = 3
        self.expenseSharedMemberTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseSharedMemberTextField.attributedPlaceholder = NSAttributedString(string: "SHARED FRIEND", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseAmountTextField.layer.borderWidth = 3
        self.expenseAmountTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseAmountTextField.attributedPlaceholder = NSAttributedString(string: "SHARED AMOUNT", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.expenseDescriptionTextField.layer.borderWidth = 3
        self.expenseDescriptionTextField.layer.borderColor = UIColor.white.cgColor
        self.expenseDescriptionTextField.attributedPlaceholder = NSAttributedString(string: "DESCRIPTION", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        userPercentLabel.isHidden = true
        friendPercentLabel.isHidden = true
        userSharedPercentTextField.isHidden = true
        friendSharedPercentTextField.isHidden = true

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_navigate_before_white_36pt"), style: .plain, target: self, action: #selector(touchBackButton))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.title = "ADD EXPENSE"

    }

    func touchBackButton() {

        self.navigationController?.popViewController(animated: true)

    }

    func touchShareExpenseEquallyButton() {

        guard let totalAmountText = expenseAmountTextField.text
            else { return }

        let totalAmount: Double = Double(totalAmountText) ?? 0

        userSharedAmountTextField.text = "\(Int(round(totalAmount / 2)))"
        friendSharedAmountTextField.text = "\(Int(floor(totalAmount / 2)))"

        shareExpenseByPercentButton.backgroundColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        shareExpenseByPercentButton.setTitleColor(UIColor.white, for: .normal)

        shareExpenseEquallyButton.backgroundColor = UIColor.white
        shareExpenseEquallyButton.setTitleColor(UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0), for: .normal)

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

        shareExpenseByPercentButton.backgroundColor = UIColor.white
        shareExpenseByPercentButton.setTitleColor(UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0), for: .normal)

        shareExpenseEquallyButton.backgroundColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        shareExpenseEquallyButton.setTitleColor(UIColor.white, for: .normal)

        sharedMethod = SharedMethod.byPercent

    }

    func userSharedPercentTextFieldChanged() {

        guard let userSharedPercentText = userSharedPercentTextField.text
            else { return }

        let userSharedPercent = Int(userSharedPercentText) ?? 0

        if userSharedPercent > 100 {

            let alertController = UIAlertController(title: "Oops!", message: "Shared percent can't be more than 100%", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

            friendSharedPercentTextField.text = "0"
            userSharedPercentTextField.text = "\(100)"

        } else {

            friendSharedPercentTextField.text = "\(100 - userSharedPercent)"
            userSharedPercentTextField.text = "\(userSharedPercent)"

        }

    }

    func friendSharedPercentTextFieldChanged() {

        guard let friendSharedPercentText = friendSharedPercentTextField.text
            else { return }

        let friendSharedPercent = Int(friendSharedPercentText) ?? 0

        if friendSharedPercent > 100 {

            let alertController = UIAlertController(title: "Oops!", message: "Shared percent can't be more than 100%", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

            userSharedPercentTextField.text = "0"
            friendSharedPercentTextField.text = "\(100)"

        } else {

            userSharedPercentTextField.text = "\(100 - friendSharedPercent)"
            friendSharedPercentTextField.text = "\(friendSharedPercent)"
        }

    }

    func userSharedAmountTextFieldChagned() {

        guard
            let totalAmountText = expenseAmountTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil),
            let userSharedAmountText = userSharedAmountTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            else { return }

        let totalAmount = Int(totalAmountText) ?? 0,
            userSharedAmount = Int(userSharedAmountText) ?? 0

        if totalAmount - userSharedAmount < 0 {

            let alertController = UIAlertController(title: "Oops!", message: "Shared amount can't be more than total amount", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

            friendSharedAmountTextField.text = "0"
            userSharedAmountTextField.text = "\((totalAmount))".currencyInputFormatting()

        } else {

            friendSharedAmountTextField.text = "\((totalAmount - userSharedAmount))".currencyInputFormatting()
            userSharedAmountTextField.text = "\(userSharedAmount)".currencyInputFormatting()

        }

    }

    func friendSharedAmountTextFieldChagned() {

        guard
            let totalAmountText = expenseAmountTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil),
            let friendSharedAmountText = friendSharedAmountTextField.text?.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            else { return }

        let totalAmount = Int(totalAmountText) ?? 0,
        friendSharedAmount = Int(friendSharedAmountText) ?? 0

        if totalAmount - friendSharedAmount < 0 {

            let alertController = UIAlertController(title: "Oops!", message: "Shared amount can't be more than total amount", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

            userSharedAmountTextField.text = "0"
            friendSharedAmountTextField.text = "\((totalAmount))".currencyInputFormatting()

        } else {

            userSharedAmountTextField.text = "\((totalAmount - friendSharedAmount))".currencyInputFormatting()
            friendSharedAmountTextField.text = "\(friendSharedAmount)".currencyInputFormatting()

        }

    }

    func touchPaidByUser(_ sender: UIButton) {

        paidByResult = PaidBy.user

        paidByFriendButton.backgroundColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        paidByFriendButton.setTitleColor(UIColor.white, for: .normal)

        paidByUserButton.backgroundColor = UIColor.white
        paidByUserButton.setTitleColor(UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0), for: .normal)

    }

    func touchPaidByFriend(_ sender: UIButton) {

        paidByResult = PaidBy.friend

        paidByFriendButton.backgroundColor = UIColor.white
        paidByFriendButton.setTitleColor(UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0), for: .normal)

        paidByUserButton.backgroundColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        paidByUserButton.setTitleColor(UIColor.white, for: .normal)

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

        guard let amountText = sender.text
            else { return }

        if let amountString = expenseAmountTextField.text?.currencyInputFormatting() {
            expenseAmountTextField.text = amountString
        }

        if amountText.characters.count > 9 {

            expenseAmountTextField.deleteBackward()

            let alertController = UIAlertController(title: "Oops!", message: "Amount cannot have more than 7 digits", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)

        } else {

            let amountWithoutComma = amountText.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)

            let amount: Double = Double(amountWithoutComma) ?? 0

            userSharedAmountTextField.text = "\(Int(round(amount / 2)))".currencyInputFormatting()
            friendSharedAmountTextField.text = "\(Int(floor(amount / 2)))".currencyInputFormatting()

        }

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

        if friendNameList[row].characters.count > 7 {

            paidByFriendButton.setTitle("Friend", for: .normal)
            friendSharesLabel.text = "Friend\nSHARES"

        } else {

            paidByFriendButton.setTitle(friendNameList[row], for: .normal)
            friendSharesLabel.text = "\(friendNameList[row])\nSHARES"

        }

    }

    func setUpGesture() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))

        swipeRight.direction = .right

        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {

        if gesture.direction == UISwipeGestureRecognizerDirection.right {

            self.navigationController?.popViewController(animated: true)
            
        }
    }

}
