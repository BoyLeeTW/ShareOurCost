//
//  File.swift
//  ShareOurCost
//
//  Created by Brad on 28/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Foundation

var userUID = String()

var friendUIDandNameList = [String: String]()

var friendNameAndUIDList = [String: String]()

var friendUIDList = Array<String>()

typealias ExpenseInfoList = [String: [[String: Any]]]

enum ExpenseStatus: String {
    
    case accepted = "accepted"
    case sentPending = "sentPending"
    case receivedPending = "receivedPending"
    case denied = "denied"
    case receivedDeleted = "receivedDeleted"
    
}

class MyButton: UIButton {

    var section: Int?
    var row: Int?

}

struct Expense {

    var ID: Int
    var totalAmount: Int
    var dexsription: String
    var sharedMember: String
    var paidBy: String
    var createdTime: String
    var createdBy: String
    var sharedWith: String
    var sharedResult: [String: Int]

}

struct Friend {

    var firebaseUID: String
    var Name: String
    var userID: String

}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 0

        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber
            else {
                return ""
        }
        
        return formatter.string(from: number)!
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
