//
//  ExpenseListTableViewController.swift
//  ShareOurCost
//
//  Created by Brad on 02/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ExpenseListTableViewController: UITableViewController {

    @IBOutlet var expenseListTableView: UITableView!

    var ref: DatabaseReference!

    var expenseIDList = [String]()

    var recievedPendingExpenseIDList = [String]()

    var sentPendingExpenseIDList = [String]()

    var deniedExpenseIDList = [String]()

    var selectedRow = Int()

    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        ref = Database.database().reference()

        ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").queryOrderedByValue().queryEqual(toValue: "receivedPending").observe(.childAdded, with: { (dataSnapshot) in

            self.recievedPendingExpenseIDList.append(dataSnapshot.key)

            self.expenseListTableView.reloadData()

        })

        ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").queryOrderedByValue().queryEqual(toValue: "sentPending").observe(.childAdded, with: { (dataSnapshot) in

            self.sentPendingExpenseIDList.append(dataSnapshot.key)

            self.expenseListTableView.reloadData()

        })

        ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").queryOrderedByValue().queryEqual(toValue: "accepted").observe(.childAdded, with: { (dataSnapshot) in

            self.expenseIDList.append(dataSnapshot.key)

            self.expenseListTableView.reloadData()

        })

        ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").queryOrderedByValue().queryEqual(toValue: "denied").observe(.childAdded, with: { (dataSnapshot) in

            self.deniedExpenseIDList.append(dataSnapshot.key)

            self.expenseListTableView.reloadData()

        })

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    override func viewWillAppear(_ animated: Bool) {

        self.expenseListTableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let sections = ["Expense", "Pending Received Expense", "Pending Sent Expense", "Denied Sent Expense"]

        return sections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 0:

            if expenseIDList.count == 0 {

                return 1

            } else {

                return expenseIDList.count

            }

        case 1:

            if expenseIDList.count == 0 {

                return 1

            } else {

                return recievedPendingExpenseIDList.count

            }

        case 2:

            if expenseIDList.count == 0 {

                return 1

            } else {

                return sentPendingExpenseIDList.count

            }

        default:

            if deniedExpenseIDList.count == 0 {

                return 1

            } else {

                return deniedExpenseIDList.count

            }

        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseListCell", for: indexPath) as? ExpenseListTableViewCell else { return UITableViewCell() }

            if expenseIDList.count == 0 {

                cell.expenseNameLabel.text = "nothing here"

            } else {

                ref.database.reference().child("expenseList").child((expenseIDList)[indexPath.row]).child("sharedResult").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    guard let sharedAmount = dataSnapshot.value! as? Int else { return }

                    //someone owe you money
                    if sharedAmount > 0 {
                        
                        self.ref.database.reference().child("expenseList").child((self.expenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "\(dataSnapshot.value!) owes you $\(sharedAmount)"
                                    
                                })
                                
                            }
                            
                        })
                        
                        // you owe someone money
                    } else {
                        
                        self.ref.database.reference().child("expenseList").child((self.expenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "You owe \(dataSnapshot.value!) $\(-sharedAmount)"
                                    
                                })
                                
                            }
                            
                        })
                        
                    }
                    
                })
                
            }

            return cell

        case 1:

        if recievedPendingExpenseIDList.count == 0 {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseListCell", for: indexPath) as? ExpenseListTableViewCell else { return UITableViewCell() }
            
            cell.expenseNameLabel.text = "nothing here"
            
            return cell
            
        } else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pendingExpenseListCell", for: indexPath) as? PendingExpenseListTableViewCell else { return UITableViewCell() }

            ref.database.reference().child("expenseList").child((recievedPendingExpenseIDList)[indexPath.row]).child("sharedResult").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard let sharedAmount = dataSnapshot.value! as? Int else { return }

                //someone owe you money
                if sharedAmount > 0 {

                    self.ref.database.reference().child("expenseList").child((self.recievedPendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in

                        if dataSnapshot.key != Auth.auth().currentUser!.uid {

                            self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                                cell.pendingExpenseNameLabel.text = "\(dataSnapshot.value!) owes you $\(sharedAmount)"

                            })

                        }

                    })

                    // you owe someone money
                } else {

                    self.ref.database.reference().child("expenseList").child((self.recievedPendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in

                        if dataSnapshot.key != Auth.auth().currentUser!.uid {

                            self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                                cell.pendingExpenseNameLabel.text = "You owe \(dataSnapshot.value!) $\(-sharedAmount)"

                            })

                        }

                    })

                }

            })

            cell.acceptExpenseButton.tag = indexPath.row
            
            cell.acceptExpenseButton.addTarget(self, action: #selector(handleAcceptFriend), for: .touchUpInside)

            return cell

        }

        case 2:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseListCell", for: indexPath) as? ExpenseListTableViewCell else { return UITableViewCell() }

            if sentPendingExpenseIDList.count == 0 {

                cell.expenseNameLabel.text = "nothing here"

            } else {

                ref.database.reference().child("expenseList").child((sentPendingExpenseIDList)[indexPath.row]).child("sharedResult").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    guard let sharedAmount = dataSnapshot.value! as? Int else { return }

                    //someone owe you money
                    if sharedAmount > 0 {

                        self.ref.database.reference().child("expenseList").child((self.sentPendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "\(dataSnapshot.value!) owes you $\(sharedAmount)"
                                    
                                })
                                
                            }
                            
                        })
                        
                        // you owe someone money
                    } else {
                        
                        self.ref.database.reference().child("expenseList").child((self.sentPendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "You owe \(dataSnapshot.value!) $\(-sharedAmount)"

                                })

                            }

                        })

                    }

                })

            }

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseListCell", for: indexPath) as? ExpenseListTableViewCell else { return UITableViewCell() }

            if deniedExpenseIDList.count == 0 {

                cell.expenseNameLabel.text = "nothing here"

            } else {

                ref.database.reference().child("expenseList").child((deniedExpenseIDList)[indexPath.row]).child("sharedResult").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    guard let sharedAmount = dataSnapshot.value! as? Int else { return }
                    
                    //someone owe you money
                    if sharedAmount > 0 {
                        
                        self.ref.database.reference().child("expenseList").child((self.deniedExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "\(dataSnapshot.value!) owes you $\(sharedAmount)"
                                    
                                })
                                
                            }
                            
                        })
                        
                        // you owe someone money
                    } else {
                        
                        self.ref.database.reference().child("expenseList").child((self.deniedExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                            
                            if dataSnapshot.key != Auth.auth().currentUser!.uid {
                                
                                self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                                    
                                    cell.expenseNameLabel.text = "You owe \(dataSnapshot.value!) $\(-sharedAmount)"
                                    
                                })
                                
                            }
                            
                        })
                        
                    }
                    
                })
                
            }

            return cell

        }

    }

    func handleAcceptFriend(_ sender: UIButton) {

        let expenseID = recievedPendingExpenseIDList[sender.tag]

        ref = Database.database().reference()

        ref.child("expenseList").child(expenseID).child("createdBy").observeSingleEvent(of: .value, with: { (dataSnapshot) in

            if let createdUserID = dataSnapshot.value! as? String {

                self.ref.child("expenseList").child(expenseID).child("sharedWith").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                    if let sharedUserID = dataSnapshot.value! as? String {

                        self.ref.child("userExpense").child(createdUserID).updateChildValues([expenseID: "accepted"])

                        self.ref.child("userExpense").child(sharedUserID).updateChildValues([expenseID: "accepted"])

                        self.recievedPendingExpenseIDList.remove(at: sender.tag)
                        
                    }
                })
            }

        })

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedRow = indexPath.row

        switch indexPath.section {

        case 0:

            selectedSection = 0

        case 1:

            selectedSection = 1

        case 2:

            selectedSection = 2

        default:

            selectedSection = 3
 
        }

        self.performSegue(withIdentifier: "showExpenseDetailVC", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showExpenseDetailVC" {

            let expenseDetailNC = segue.destination as? UINavigationController

            let destinationVC = expenseDetailNC?.viewControllers.first
                as? ExpeneseDetailViewController
            
            switch selectedSection {
            case 0 :

                destinationVC?.expenseID = self.expenseIDList[selectedRow]

            case 1:

                destinationVC?.expenseID = self.recievedPendingExpenseIDList[selectedRow]

            case 2:

                destinationVC?.expenseID = self.sentPendingExpenseIDList[selectedRow]

            default:

                destinationVC?.expenseID = self.deniedExpenseIDList[selectedRow]

            }

        }

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
