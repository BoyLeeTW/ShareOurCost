//
//  ExpenseManager.swift
//  ShareOurCost
//
//  Created by Brad on 07/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Firebase
import Foundation
import NVActivityIndicatorView

class ExpenseManager {

    typealias ExpenseInfoList = [String: [[String: Any]]]

    var ref: DatabaseReference!

    func newFetchExpenseIDList(completion: @escaping (ExpenseInfoList, ExpenseInfoList, ExpenseInfoList, ExpenseInfoList, ExpenseInfoList) -> () ) {

        ref = Database.database().reference()

        ref.child("userExpense").child(userUID).observe(.value, with: { (dataSnapshot) in

            var acceptedExpenseIDList = ExpenseInfoList()

            var sentPendingExpenseIDList = ExpenseInfoList()

            var receivedPendingExpenseIDList = ExpenseInfoList()

            var deniedExpenseIDList = ExpenseInfoList()

            var receivedDeletedExpenseIDList = ExpenseInfoList()

            //key is the ID of expense
            guard let expenseData = dataSnapshot.value as? [String: Any]

            else {

                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                return

            }

            for (key, value) in expenseData {

                guard let expenseStatusDic = value as? [String: Any],
                      let isReadStatus = expenseStatusDic["isRead"] as? Bool,
                      let expenseStatus = expenseStatusDic["status"] as? String
                else { return }

                self.ref.child("expenseList").child(key).observe(.value, with: { (dataSnapshot) in

                    var sharedFriendID = String()

                    guard let expenseDetailData = dataSnapshot.value as? [String: Any],
                          let expenseCreatedBy = expenseDetailData["createdBy"] as? String,
                          let expenseSahreWith = expenseDetailData["sharedWith"] as? String
                    else { return }

                    if expenseCreatedBy == userUID {
                        
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

                    } else if expenseStatus == ExpenseStatus.denied.rawValue {

                        if deniedExpenseIDList[sharedFriendID] == nil {
                            
                            deniedExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)
                            
                        } else {

                            deniedExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)

                        }

                    } else if expenseStatus == ExpenseStatus.receivedDeleted.rawValue {

                        if receivedDeletedExpenseIDList[sharedFriendID] == nil {

                            receivedDeletedExpenseIDList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)

                        } else {

                            receivedDeletedExpenseIDList[sharedFriendID]?.append(expenseDetailDataVar)

                        }

                    }

                    DispatchQueue.main.async {

                        completion(acceptedExpenseIDList,
                                   receivedPendingExpenseIDList,
                                   sentPendingExpenseIDList,
                                   deniedExpenseIDList,
                                   receivedDeletedExpenseIDList)

                    }

                })

                self.ref.child("expenseList").removeAllObservers()

            }

        })

    }

    func changeExpenseStatus(friendUID: String,
                             expenseID: String,
                             changeSelfStatus: String,
                             changeFriendStatus: String? )

    {

        ref = Database.database().reference()

        if changeFriendStatus == nil {

            ref.child("userExpense").child(userUID).child(expenseID).updateChildValues(["status": changeSelfStatus])
            ref.child("userExpense").child(friendUID).child(expenseID).updateChildValues(["status": changeSelfStatus])

        } else {

            ref.child("userExpense").child(userUID).child(expenseID).updateChildValues(["status": changeSelfStatus])
            ref.child("userExpense").child(friendUID).child(expenseID).updateChildValues(["status": changeFriendStatus!])

        }

    }

    func changeExpenseReadStatus(friendUID: String, expenseID: String, changeSelfStatus: Bool, changeFriendStatus: Bool?) {

        ref = Database.database().reference()

        ref.child("userExpense").child(userUID).child(expenseID).updateChildValues(["isRead": changeSelfStatus])

        if changeFriendStatus != nil {

            ref.child("userExpense").child(friendUID).child(expenseID).updateChildValues(["isRead": changeFriendStatus!])

        }

    }

    func fetchAcceptedExpenseList(completion: @escaping (ExpenseInfoList) -> () ) {

        ref = Database.database().reference()

        ref.child("userExpense").child(userUID).queryOrdered(byChild: "status").queryEqual(toValue: "accepted").observe(.value, with: { (dataSnapshot) in

            var acceptedExpenseList = ExpenseInfoList()

            //key is the ID of expense
            guard let expenseData = dataSnapshot.value as? [String: Any]

            else {

                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                return

            }

            for (key, value) in expenseData {

                guard let expenseStatusDic = value as? [String: Any],
                      let isReadStatus = expenseStatusDic["isRead"] as? Bool,
                      let expenseStatus = expenseStatusDic["status"] as? String
                else { return }

                self.ref.child("expenseList").child(key).observe(.value, with: { (dataSnapshot) in

                    var sharedFriendID = String()

                    guard let expenseDetailData = dataSnapshot.value as? [String: Any],
                          let expenseCreatedBy = expenseDetailData["createdBy"] as? String,
                          let expenseSahreWith = expenseDetailData["sharedWith"] as? String
                    else { return }

                    if expenseCreatedBy == userUID {

                        sharedFriendID = expenseSahreWith

                    } else {

                        sharedFriendID = expenseCreatedBy

                    }

                    var expenseDetailDataVar = expenseDetailData
                    
                    expenseDetailDataVar.updateValue(isReadStatus, forKey: "isRead")
                    expenseDetailDataVar.updateValue(expenseStatus, forKey: "status")
                    expenseDetailDataVar.updateValue(key, forKey: "id")

                    if acceptedExpenseList[sharedFriendID] == nil {

                        acceptedExpenseList.updateValue([expenseDetailDataVar], forKey: sharedFriendID)

                    } else {

                        acceptedExpenseList[sharedFriendID]?.append(expenseDetailDataVar)

                    }

                    DispatchQueue.main.async {

                        completion(acceptedExpenseList)

                    }

                })

                self.ref.child("expenseList").removeAllObservers()

            }

        })

    }

    func settleUpBalance(friendUID: String, expenseIDList: Array<String>) {

        ref = Database.database().reference()

        for expenseID in expenseIDList {

            ref.child("expenseList").child(expenseID).removeValue()
            ref.child("userExpense").child(friendUID).child(expenseID).removeValue()
            ref.child("userExpense").child(userUID).child(expenseID).removeValue()
        }

    }

    func deleteExpense(friendUID: String, expenseID: String) {

        ref = Database.database().reference()
        ref.child("expenseList").child(expenseID).removeValue()
        ref.child("userExpense").child(friendUID).child(expenseID).removeValue()
        ref.child("userExpense").child(userUID).child(expenseID).removeValue()

    }

}
