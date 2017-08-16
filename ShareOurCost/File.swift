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

var friendNameList = Array<String>()

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
