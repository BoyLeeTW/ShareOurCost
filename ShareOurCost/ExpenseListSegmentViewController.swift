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

    typealias ExpenseIDList = [String: [[String: Any]]]

    var friendManager = FriendManager()

    var expenseManager = ExpenseManager()

    var friendUIDList = [String]()

    var friendUIDtoNameList = [String: String]()

    var acceptedExpenseIDList = ExpenseIDList()

    var receivedPendingExpenseIDList = ExpenseIDList()

    var sentPendingExpenseIDList = ExpenseIDList()

    var deniedExpenseIDList = ExpenseIDList()

    var toBeDeletedExpenseIDList = ExpenseIDList()

    var selectedRow = Int()

    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        expenseStatusSegmentController.addTarget(self, action: #selector(expenseStatusSegmentControllerChanged), for: .valueChanged)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        fetchData()

    }

    func fetchData() {

        DispatchQueue.global().async {
            
            self.friendManager.fetchFriendUIDList { (friendUIDList) in
                
                self.friendUIDList = friendUIDList
                
                self.friendManager.fetchFriendUIDtoNameList(friendUIDList: self.friendUIDList, completion: { (friendUIDtoNameList) in
                    
                    friendUIDandNameList = friendUIDtoNameList
                    
                    self.friendUIDtoNameList = friendUIDtoNameList
                    
                    self.expenseListTableView.reloadData()
                    
                })
                
                self.expenseManager.newFetchExpenseIDList { (acceptedExpenseIDList, receivedPendingExpenseIDList, sentPendingExpenseIDList, deniedExpenseIDList, toBeDeletedExpenseIDList) in
                    
                    self.acceptedExpenseIDList = acceptedExpenseIDList
                    self.receivedPendingExpenseIDList = receivedPendingExpenseIDList
                    self.sentPendingExpenseIDList = sentPendingExpenseIDList
                    self.deniedExpenseIDList = deniedExpenseIDList
                    self.toBeDeletedExpenseIDList = toBeDeletedExpenseIDList
                    
                    self.expenseListTableView.reloadData()
                    
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        fetchData()

        self.expenseListTableView.reloadData()

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func expenseStatusSegmentControllerChanged() {

        expenseListTableView.reloadData()

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return friendUIDtoNameList[friendUIDList[section]]
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

        case 3:

            rowInSection = deniedExpenseIDList[friendUIDList[section]]?.count ?? 0

        default:

            rowInSection = toBeDeletedExpenseIDList[friendUIDList[section]]?.count ?? 0

        }

        return rowInSection

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        switch expenseStatusSegmentController.selectedSegmentIndex {
        case 0:

            guard let expenseData = acceptedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                  let expenseDescription = expenseData["description"] as? String,
                  let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                  let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]

            else { return cell }

            if isRead == true {
                
                cell.contentView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.contentView.backgroundColor = UIColor.yellow
                
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        case 1:

        guard let expenseData = receivedPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
            let dicArray = receivedPendingExpenseIDList[friendUIDList[indexPath.section]],
            let expenseDescription = expenseData["description"] as? String,
            let sharedResult = expenseData["sharedResult"] as? [String: Int],
            let isRead = expenseData["isRead"] as? Bool,
            let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
        
            else { return cell }

        for (key, value) in sharedResult where value < 0 {
            
            if key == userUID {
                
                cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                
            } else {
                
                cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                
            }
            
        }

        if isRead == true {

            cell.contentView.backgroundColor = UIColor.clear

        } else {

            cell.contentView.backgroundColor = UIColor.yellow

        }

        cell.acceptButton.isHidden = false
        cell.denyButton.isHidden = false

        cell.acceptButton.section = indexPath.section
        cell.acceptButton.row = indexPath.row
        cell.denyButton.section = indexPath.section
        cell.denyButton.row = indexPath.row

        cell.acceptButton.addTarget(self, action: #selector(self.touchAcceptButton(sender:)), for: .touchUpInside)

        cell.denyButton.addTarget(self, action: #selector(self.touchDenyButton(sender:)), for: .touchUpInside)

        case 2:

            guard let expenseData = sentPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }

            if isRead == true {
                
                cell.contentView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.contentView.backgroundColor = UIColor.yellow
                
            }
            
            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        case 3:

            guard let expenseData = deniedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }
            
            if isRead == true {
                
                cell.contentView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.contentView.backgroundColor = UIColor.yellow
                
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }
            
            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true


        default:

            guard let expenseData = toBeDeletedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }
            
            if isRead == true {
                
                cell.contentView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.contentView.backgroundColor = UIColor.yellow
                
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }
            
            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        cell.friendNameLabel.text = ""
        cell.acceptButton.isHidden = true
        cell.denyButton.isHidden = true
        cell.contentView.backgroundColor = UIColor.clear

    }

    func touchAcceptButton(sender: MyButton) {

        guard let expenseID = receivedPendingExpenseIDList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
              let friendUID = friendUIDList[sender.section!] as? String
        else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeStatus: "accepted")

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

    }

    func touchDenyButton(sender: MyButton) {

        guard let expenseID = receivedPendingExpenseIDList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeStatus: "denied")

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedRow = indexPath.row

        selectedSection = indexPath.section

        switch expenseStatusSegmentController.selectedSegmentIndex {
        case 0:

            guard let expenseID = acceptedExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        case 1:

            guard let expenseID = receivedPendingExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)


        case 2:

            guard let expenseID = sentPendingExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)


        case 3:

            guard let expenseID = deniedExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        default:

            guard let expenseID = toBeDeletedExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        }

        self.performSegue(withIdentifier: "showExpenseDetailVC", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showExpenseDetailVC" {

            let destinationVC = segue.destination as? ExpeneseDetailViewController

            switch expenseStatusSegmentController.selectedSegmentIndex {

            case 0:

                destinationVC?.expenseInformation = (acceptedExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!
                
            case 1:

                destinationVC?.expenseInformation = (receivedPendingExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

            case 2:

                destinationVC?.expenseInformation = (sentPendingExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

            case 3:

                destinationVC?.expenseInformation = (deniedExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

            default:

                destinationVC?.expenseInformation = (toBeDeletedExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!


            }

        }

    }

}
