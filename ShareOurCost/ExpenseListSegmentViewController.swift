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

    var recievedPendingExpenseIDList = [String: [String]]()

    var sentPendingExpenseIDList = [String: [String]]()

    var deniedExpenseIDList = [String: [String]]()

    var selectedRow = Int()

    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        friendManager.fetchFriendUIDList { (friendUIDList) in

            self.friendUIDList = friendUIDList

            self.expenseManager.fetchExpenseIDList(friendUIDList: friendUIDList, completion: { (acceptedExpenseIDList, sentPendingExpenseIDList, receivedPendingExpenseIDList, deniedExpenseIDList) in
                self.acceptedExpenseIDList = acceptedExpenseIDList
                self.sentPendingExpenseIDList = sentPendingExpenseIDList
                self.recievedPendingExpenseIDList = receivedPendingExpenseIDList
                self.deniedExpenseIDList = deniedExpenseIDList

                self.expenseListTableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendUIDList[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return friendUIDList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let rowInSction = acceptedExpenseIDList[friendUIDList[section]]?.count else { return 0 }

        return rowInSction
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        cell.friendNameLabel.text = "A"

        return cell
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
