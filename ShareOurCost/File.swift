//
//  File.swift
//  ShareOurCost
//
//  Created by Brad on 28/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation


class ExpenseModel{

    var amount: Int
    var date: String
    var member: String
    var sharedMethod: String
    var sharedResult: Dictionary<String, Int>
    
    init(amount: Int, date:String, member:String, sharedMethod:String, sharedResult:Dictionary<String, Int>){
        self.amount = amount
        self.date = date
        self.member = member
        self.sharedMethod = sharedMethod
        self.sharedResult = sharedResult
    }
}
