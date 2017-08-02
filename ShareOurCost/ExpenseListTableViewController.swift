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

    var pendingExpenseIDList = [String]()

    var deniedExpenseIDList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        ref = Database.database().reference()

        ref.child("userExpense").child("\(Auth.auth().currentUser!.uid)").queryOrderedByValue().queryEqual(toValue: "pending").observe(.childAdded, with: { (dataSnapshot) in

            self.pendingExpenseIDList.append(dataSnapshot.key)

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let sections = ["Expense", "Pending Sent Expense", "Denied Sent Expense"]

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

            return pendingExpenseIDList.count

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

                cell.expenseNameLabel.text = expenseIDList[indexPath.row]

            }

            return cell

        case 1:

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pendingExpenseListCell", for: indexPath) as? PendingExpenseListTableViewCell else { return UITableViewCell() }

        if pendingExpenseIDList.count == 0 {

            cell.pendingExpenseNameLabel.text = "nothing here"

        } else {

            ref.database.reference().child("expenseList").child((pendingExpenseIDList)[indexPath.row]).child("sharedResult").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard let sharedAmount = dataSnapshot.value! as? Int else { return }

                print(type(of: sharedAmount))

                if sharedAmount > 0 {

                    print("someone owe you money~~")

                    self.ref.database.reference().child("expenseList").child((self.pendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                        print(dataSnapshot.key)

                        if dataSnapshot.key != Auth.auth().currentUser!.uid {

                            self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                                cell.pendingExpenseNameLabel.text = "\(dataSnapshot.value!) owes you \(sharedAmount)"

                            })

                        }

                    })

                } else {

                    print("you owe someone money yo!")

                    self.ref.database.reference().child("expenseList").child((self.pendingExpenseIDList)[indexPath.row]).child("sharedResult").observe(.childAdded, with: { (dataSnapshot) in
                        print(dataSnapshot.key)

                        if dataSnapshot.key != Auth.auth().currentUser!.uid {

                            self.ref.database.reference().child("userInfo").child("\(dataSnapshot.key)").child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                                cell.pendingExpenseNameLabel.text = "\(dataSnapshot.value!) owes you \(-sharedAmount)"

                            })

                        }

                    })

                }

            })

            cell.pendingExpenseNameLabel.text = pendingExpenseIDList[indexPath.row]

        }

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseListCell", for: indexPath) as? ExpenseListTableViewCell else { return UITableViewCell() }

            if deniedExpenseIDList.count == 0 {

                cell.expenseNameLabel.text = "nothing here"

            } else {

                cell.expenseNameLabel.text = expenseIDList[indexPath.row]

            }

            return cell

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
