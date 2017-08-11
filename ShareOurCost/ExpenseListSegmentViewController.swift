//
//  ExpenseListSegmentViewController.swift
//  ShareOurCost
//
//  Created by Brad on 11/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class ExpenseListSegmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum ExpenseStatus {

        case accepted
        case sentPending
        case receivedPending
        case denied

    }

    @IBOutlet weak var expenseStatusSegmentController: UISegmentedControl!
    @IBOutlet weak var expenseListTableView: UITableView!

    var friendManager = FriendManager()

    var expenseManager = ExpenseManager()

    var friendUIDList = [String]()

    var acceptedExpenseIDList = [String: [String]]()

    var receivedPendingExpenseIDList = [String: [String]]()

    var sentPendingExpenseIDList = [String: [String]]()

    var deniedExpenseIDList = [String: [String]]()

    var selectedRow = Int()

    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        expenseStatusSegmentController.addTarget(self, action: #selector(expenseStatusSegmentControllerChanged), for: .valueChanged)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        friendManager.fetchFriendUIDList { (friendUIDList) in

            self.friendUIDList = friendUIDList

            self.expenseManager.fetchExpenseIDList(friendUIDList: friendUIDList, completion: { (acceptedExpenseIDList, sentPendingExpenseIDList, receivedPendingExpenseIDList, deniedExpenseIDList) in
                self.acceptedExpenseIDList = acceptedExpenseIDList
                self.sentPendingExpenseIDList = sentPendingExpenseIDList
                self.receivedPendingExpenseIDList = receivedPendingExpenseIDList
                self.deniedExpenseIDList = deniedExpenseIDList

                self.expenseListTableView.reloadData()
            })
        }
    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func expenseStatusSegmentControllerChanged() {

        expenseListTableView.reloadData()

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendUIDList[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return friendUIDList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var rowInSection = 0

        switch expenseStatusSegmentController.selectedSegmentIndex {

        case 0:

            rowInSection = acceptedExpenseIDList[friendUIDList[section]]?.count ?? 0

        case 1:

            rowInSection = receivedPendingExpenseIDList[friendUIDList[section]]?.count ?? 0

        case 2:

            rowInSection = sentPendingExpenseIDList[friendUIDList[section]]?.count ?? 0

        default:

            rowInSection = deniedExpenseIDList[friendUIDList[section]]?.count ?? 0

        }

        return rowInSection

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        switch expenseStatusSegmentController.selectedSegmentIndex {
        case 0:

            expenseManager.fetchExpenseDetail(friendUID: friendUIDList[indexPath.section], expenseID: (acceptedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row])!, completion: { (sharedResult) in
                
                cell.friendNameLabel.text = sharedResult
                cell.acceptButton.isHidden = true
                cell.denyButton.isHidden = true

            })

        case 1:

            expenseManager.fetchExpenseDetail(friendUID: friendUIDList[indexPath.section], expenseID: (receivedPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row])!, completion: { (sharedResult) in

                cell.friendNameLabel.text = sharedResult
            })

        case 2:

            expenseManager.fetchExpenseDetail(friendUID: friendUIDList[indexPath.section], expenseID: (sentPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row])!, completion: { (sharedResult) in
                
                cell.friendNameLabel.text = sharedResult
                cell.acceptButton.isHidden = true
                cell.denyButton.isHidden = true

            })

        default:

            expenseManager.fetchExpenseDetail(friendUID: friendUIDList[indexPath.section], expenseID: (deniedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row])!, completion: { (sharedResult) in
                
                cell.friendNameLabel.text = sharedResult
                cell.acceptButton.isHidden = true
                cell.denyButton.isHidden = true

            })

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        cell.friendNameLabel.text = ""

    }

    func touchAcceptButton(sender: UIButton) {

        

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
