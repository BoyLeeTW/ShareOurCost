//
//  ExpenseManager.swift
//  ShareOurCost
//
//  Created by Brad on 07/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation
import Firebase

enum ExpenseStatus: String {

    case accepted = "accepted"
    case sentPending = "sentPending"
    case receivedPending = "receivedPending"
    case denied = "denied"

}

class ExpenseManager {

    typealias ExpenseList = [String: [String]]

    typealias ExpenseInfoList = [String: [[String: Any]]]

    var ref: DatabaseReference!

    func fetchExpenseIDList(friendUIDList: Array<String>, completion:@escaping (ExpenseList, ExpenseList, ExpenseList, ExpenseList) -> () ) {

        ref = Database.database().reference()

        for friendUID in friendUIDList {

            ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").child("\(friendUID)").observe(.value, with: { (dataSnapshot) in

                var acceptedExpenseIDList = ExpenseList()
                
                var sentPendingExpenseIDList = ExpenseList()
                
                var receivedPendingExpenseIDList = ExpenseList()
                
                var deniedExpenseIDList = ExpenseList()

                guard let expenseListData = dataSnapshot.value! as? [String: String] else { return }

                for (key, value) in expenseListData {

                    if value == ExpenseStatus.accepted.rawValue {

                        if acceptedExpenseIDList[friendUID] == nil {

                            acceptedExpenseIDList.updateValue([key], forKey: friendUID)

                        } else {

                            acceptedExpenseIDList[friendUID]!.append(key)

                        }

                    } else if value == ExpenseStatus.sentPending.rawValue {

                        if sentPendingExpenseIDList[friendUID] == nil {
                            
                            sentPendingExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            sentPendingExpenseIDList[friendUID]!.append(key)
                            
                        }

                    } else if value == ExpenseStatus.receivedPending.rawValue {
                        
                        if receivedPendingExpenseIDList[friendUID] == nil {
                            
                            receivedPendingExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            receivedPendingExpenseIDList[friendUID]!.append(key)
                            
                        }
                        
                    } else if value == ExpenseStatus.denied.rawValue {
                        
                        if deniedExpenseIDList[friendUID] == nil {
                            
                            deniedExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            deniedExpenseIDList[friendUID]!.append(key)
                            
                        }
                        
                    }

                }

                completion(acceptedExpenseIDList, sentPendingExpenseIDList, receivedPendingExpenseIDList, deniedExpenseIDList)

            })

        }

    }

    func newFetchExpenseIDList(completion: @escaping (ExpenseInfoList, ExpenseInfoList, ExpenseInfoList, ExpenseInfoList) -> () ) {

        ref = Database.database().reference()

        ref.child("userExpense").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "status").observe(.value, with: { (dataSnapshot) in

            var acceptedExpenseIDList = ExpenseInfoList()
            
            var sentPendingExpenseIDList = ExpenseInfoList()
            
            var receivedPendingExpenseIDList = ExpenseInfoList()
            
            var deniedExpenseIDList = ExpenseInfoList()

            //key is the ID of expense
            guard let expenseData = dataSnapshot.value as? [String: Any] else { return }
            for (key, value) in expenseData {

                guard let expenseStatusDic = value as? [String: Any],
                    let isReadStatus = expenseStatusDic["isRead"] as? Bool,
                    let expenseStatus = expenseStatusDic["status"] as? String
                    else { return }

                self.ref.child("expenseList").child(key).observe(.value, with: { (dataSnapshot) in

                    var sharedFriendID = String()
                    
                    guard let expenseDetailData = dataSnapshot.value as? [String: Any],
                        let expenseTotalAmount = expenseDetailData["amount"] as? Int,
                        let expenseCreatedBy = expenseDetailData["createdBy"] as? String,
                        let expenseCreatedDay = expenseDetailData["createdTime"] as? String,
                        let expensePaidby = expenseDetailData["expensePaidBy"] as? String,
                        let expenseDescription = expenseDetailData["description"] as? String,
                        let expenseDay = expenseDetailData["expenseDay"] as? String,
                        let expenseSahreWith = expenseDetailData["sharedWith"] as? String,
                        let sharedAmount = expenseDetailData["sharedResult"] as? [String: Int],
                        let amountYouShared = sharedAmount["\(Auth.auth().currentUser!.uid)"]
                        else { return }
                    
                    if expenseCreatedBy == Auth.auth().currentUser!.uid {
                        
                        sharedFriendID = expenseSahreWith
                        
                    } else {
                        
                        sharedFriendID = expenseCreatedBy
                        
                    }

                    var expenseDetailDataVar = expenseDetailData

                    expenseDetailDataVar.updateValue(isReadStatus, forKey: "isRead")
                    expenseDetailDataVar.updateValue(expenseStatus, forKey: "status")
                    expenseDetailDataVar.updateValue(key, forKey: "id")

                    if expenseStatus == ExpenseStatus.accepted.rawValue {

                        if acceptedExpenseIDList[sharedFriendID] == nil {

                            acceptedExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)

                        } else {

                            acceptedExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)

                        }

                        
                    } else if expenseStatus == ExpenseStatus.receivedPending.rawValue {

                        if receivedPendingExpenseIDList[sharedFriendID] == nil {
                            
                            receivedPendingExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)
                            
                        } else {
                            
                            receivedPendingExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)
                            
                        }

                    } else if expenseStatus == ExpenseStatus.sentPending.rawValue {

                        if sentPendingExpenseIDList[sharedFriendID] == nil {
                            
                            sentPendingExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)
                            
                        } else {
                            
                            sentPendingExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)
                            
                        }


                    } else if expenseStatus == ExpenseStatus.denied.rawValue{

                        if deniedExpenseIDList[sharedFriendID] == nil {
                            
                            deniedExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)
                            
                        } else {
                            
                            deniedExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)
                            
                        }

                    }
                    
                    DispatchQueue.main.async {

                        completion(acceptedExpenseIDList, receivedPendingExpenseIDList, sentPendingExpenseIDList, deniedExpenseIDList)
                        
                    }

                })
                
            }

        })

    }

    func fetchExpenseDetail(friendUID: String, expenseID: String, completion: @escaping ((String) -> ())) {

        ref = Database.database().reference()

        ref.child("expenseList").child(expenseID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let expenseData = dataSnapshot.value as? [String: Any],
                let expenseTotalAmount = expenseData["amount"] as? Int,
                let expenseCreatedBy = expenseData["createdBy"] as? String,
                let expenseCreatedDay = expenseData["createdTime"] as? String,
                let expensePaidby = expenseData["expensePaidBy"] as? String,
                let expenseDescription = expenseData["description"] as? String,
                let expenseDay = expenseData["expenseDay"] as? String,
                let sharedAmount = expenseData["sharedResult"] as? [String: Int],
                let amountYouShared = sharedAmount["\(Auth.auth().currentUser!.uid)"]
                
                else { return }

            self.ref.child("userInfo").child(friendUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard let friendName = dataSnapshot.value as? String else { return }

                for (key, value) in sharedAmount where value < 0 {
                    
                    if key == Auth.auth().currentUser!.uid {

                        completion("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                        
                    } else {
                        
                        completion("\(friendName) owes you $\(-value) for \(expenseDescription)")
                        
                    }
                    
                }
            })

        })

        ref.removeAllObservers()

    }

    func changeExpenseStatus(friendUID: String, expenseID: String, changeStatus: String) {

        ref = Database.database().reference()

        ref.child("userExpense").child(userUID).child(expenseID).updateChildValues(["status": changeStatus])
        ref.child("userExpense").child(friendUID).child(expenseID).updateChildValues(["status": changeStatus])

    }

}
