//
//  ExpenseListTableViewController.swift
//  ShareOurCost
//
//  Created by Brad on 26/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class ExpenseSegmentedTableViewController: UITableViewController {
    @IBOutlet var expenseListTableView: UITableView!

    var expenseStatus: ExpenseStatus = ExpenseStatus.accepted

    var expenseInfoList: ExpenseInfoList = ExpenseInfoList()

    typealias ExpenseIDList = [String: [[String: Any]]]
    
    var friendManager = FriendManager()
    
    var expenseManager = ExpenseManager()
    
    var friendUIDList = [String]()
    
    var friendUIDtoNameList = [String: String]()

    var selectedRow = Int()
    
    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        self.tableView.reloadData()

    }

    func setupTableView() {

        expenseListTableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))

        expenseListTableView.estimatedRowHeight = 60.00

        expenseListTableView.rowHeight = UITableViewAutomaticDimension

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.bounds.size.width, height: 25))
        headerLabel.text = friendUIDtoNameList[friendUIDList[section]]
        headerLabel.font = UIFont(name: "Avenir-Medium", size: 16.0)
        headerLabel.textColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        
        headerView.addSubview(headerLabel)
        
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.dataSource?.tableView(expenseListTableView, numberOfRowsInSection: section) == 0 {
            
            return 0
            
        } else {
            
            return 33
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return friendUIDtoNameList[friendUIDList[section]]
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return friendUIDList.count
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return expenseInfoList[friendUIDList[section]]?.count ?? 0

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch expenseStatus {

        case .accepted, .denied, .receivedDeleted, .sentPending:

            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListCell", for: indexPath) as! ExpenseListTableViewCell

            guard let expenseData = expenseInfoList[friendUIDList[indexPath.section]]?[indexPath.row],
                let expenseDescription = expenseData["description"] as? String,
                let expenseDate = expenseData["expenseDay"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let paidBy = expenseData["expensePaidBy"] as? String,
                let totalAmount = expenseData["amount"] as? Int,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                else { return cell }
            
            if isRead == true {
                
                cell.expenseBriefLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreateDayLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.expenseBriefLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
                cell.expenseCreateDayLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
                
            }
            
            for (UID, amount) in sharedResult {
                
                if UID == userUID {
                    
                    if amount < 0 {
                        
                        cell.expenseBriefLabel.text = ("You owe \(friendName) $\(-amount) for \(expenseDescription)" )
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.expenseBriefLabel.text = ("\(friendName) owes you $\(totalAmount) for \(expenseDescription)")
                            
                        } else {
                            
                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )
                            
                        }
                        
                    }
                    
                } else {
                    
                    if amount < 0 {
                        
                        cell.expenseBriefLabel.text = ("\(friendName) owes you $\(-amount) for \(expenseDescription)")
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )
                            
                        } else {
                            
                            cell.expenseBriefLabel.text = ("You owe \(friendName) $\(totalAmount) for \(expenseDescription)" )
                            
                        }
                        
                    }
                    
                }
                
            }
            
            cell.expenseCreateDayLabel.text = expenseDate

            return cell

        case .receivedPending:

            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseRequestListCell", for: indexPath) as! ExpenseListSegmentTableViewCell

            guard let expenseData = expenseInfoList[friendUIDList[indexPath.section]]?[indexPath.row],
                let expenseDescription = expenseData["description"] as? String,
                let expenseDate = expenseData["expenseDay"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let paidBy = expenseData["expensePaidBy"] as? String,
                let totalAmount = expenseData["amount"] as? Int,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                else { return cell }
            
            for (UID, amount) in sharedResult {
                
                if UID == userUID {
                    
                    if amount < 0 {
                        
                        cell.friendNameLabel.text = ("You owe \(friendName) $\(-amount) for \(expenseDescription)" )
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.friendNameLabel.text = ("\(friendName) owes you $\(totalAmount) for \(expenseDescription)")
                            
                        } else {
                            
                            cell.friendNameLabel.text = ("You share nothing in this expense" )
                            
                        }
                        
                    }
                    
                } else {
                    
                    if amount < 0 {
                        
                        cell.friendNameLabel.text = ("\(friendName) owes you $\(-amount) for \(expenseDescription)")
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.friendNameLabel.text = ("You share nothing in this expense" )
                            
                        } else {
                            
                            cell.friendNameLabel.text = ("You owe \(friendName) $\(totalAmount) for \(expenseDescription)" )
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if isRead == true {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
            }
            
            cell.expenseCreatedDateLabel.text = expenseDate
            cell.acceptButton.isHidden = false
            cell.denyButton.isHidden = false
            
            cell.acceptButton.section = indexPath.section
            cell.acceptButton.row = indexPath.row
            cell.denyButton.section = indexPath.section
            cell.denyButton.row = indexPath.row
            
            cell.acceptButton.addTarget(self, action: #selector(self.touchAcceptButton(sender:)), for: .touchUpInside)
            
            cell.denyButton.addTarget(self, action: #selector(self.touchDenyButton(sender:)), for: .touchUpInside)

            return cell

        }
        
    }

    func touchAcceptButton(sender: MyButton) {
        
        guard let expenseID = expenseInfoList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }
        
        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "accepted", changeFriendStatus: nil)
        
        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)
        
        self.expenseListTableView.reloadData()
        
    }

    func touchDenyButton(sender: MyButton) {

        guard let expenseID = expenseInfoList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "sentDenied", changeFriendStatus: "denied")

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

        self.expenseListTableView.reloadData()

    }

}