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

    var ref: DatabaseReference!

    var acceptedExpenseIDList = ExpenseList()

    var sentPendingExpenseIDList = ExpenseList()

    var receivedPendingExpenseIDList = ExpenseList()

    var deniedExpenseIDList = ExpenseList()

    func fetchExpenseIDList(friendUIDList: Array<String>, completion:@escaping (ExpenseList, ExpenseList, ExpenseList, ExpenseList) -> () ) {

        ref = Database.database().reference()

        for friendUID in friendUIDList {

            ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").child("\(friendUID)").observe(.value, with: { (dataSnapshot) in

                guard let expenseListData = dataSnapshot.value! as? [String: String] else { return }

                for (key, value) in expenseListData {

                    if value == ExpenseStatus.accepted.rawValue {

                        if self.acceptedExpenseIDList[friendUID] == nil {

                            self.acceptedExpenseIDList.updateValue([key], forKey: friendUID)

                        } else {

                            self.acceptedExpenseIDList[friendUID]!.append(key)

                        }

                    } else if value == ExpenseStatus.sentPending.rawValue {

                        if self.sentPendingExpenseIDList[friendUID] == nil {
                            
                            self.sentPendingExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            self.sentPendingExpenseIDList[friendUID]!.append(key)
                            
                        }

                    } else if value == ExpenseStatus.receivedPending.rawValue {
                        
                        if self.receivedPendingExpenseIDList[friendUID] == nil {
                            
                            self.receivedPendingExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            self.receivedPendingExpenseIDList[friendUID]!.append(key)
                            
                        }
                        
                    } else if value == ExpenseStatus.denied.rawValue {
                        
                        if self.deniedExpenseIDList[friendUID] == nil {
                            
                            self.deniedExpenseIDList.updateValue([key], forKey: friendUID)
                            
                        } else {
                            
                            self.deniedExpenseIDList[friendUID]!.append(key)
                            
                        }
                        
                    }

                }

                completion(self.acceptedExpenseIDList, self.sentPendingExpenseIDList, self.receivedPendingExpenseIDList, self.deniedExpenseIDList)

            })

        }

    }

}
