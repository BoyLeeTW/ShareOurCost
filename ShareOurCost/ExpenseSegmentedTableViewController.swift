//
//  ExpenseListTableViewController.swift
//  ShareOurCost
//
//  Created by Brad on 26/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import FirebaseAnalytics

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

            guard
                let expenseData = expenseInfoList[friendUIDList[indexPath.section]]?[indexPath.row],
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

                        let displayAmount: String = "\(-amount)".currencyInputFormatting()

                        cell.expenseBriefLabel.text = ("You owe \(friendName) $\(displayAmount) for \(expenseDescription)" )

                    } else if amount == 0 {

                        if paidBy == userUID {

                            let displayAmount: String = "\(totalAmount)".currencyInputFormatting()

                            cell.expenseBriefLabel.text = ("\(friendName) owes you $\(displayAmount) for \(expenseDescription)")

                        } else {

                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )

                        }

                    }

                } else {

                    if amount < 0 {

                        let displayAmount: String = "\(-amount)".currencyInputFormatting()

                        cell.expenseBriefLabel.text = ("\(friendName) owes you $\(displayAmount) for \(expenseDescription)")
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )
                            
                        } else {

                            let displayAmount: String = "\(totalAmount)".currencyInputFormatting()

                            cell.expenseBriefLabel.text = ("You owe \(friendName) $\(displayAmount) for \(expenseDescription)" )
                            
                        }
                        
                    }
                    
                }
                
            }
            
            cell.expenseCreateDayLabel.text = expenseDate

            return cell

        case .receivedPending:

            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseRequestListCell", for: indexPath) as! ExpenseListApprovalTableViewCell

            guard
                let expenseData = expenseInfoList[friendUIDList[indexPath.section]]?[indexPath.row],
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

                        let displayAmount: String = "\(-amount)".currencyInputFormatting()

                        cell.expenseBriefLabel.text = ("You owe \(friendName) $\(displayAmount) for \(expenseDescription)" )

                    } else if amount == 0 {
                        
                        if paidBy == userUID {

                            let displayAmount: String = "\(totalAmount)".currencyInputFormatting()
                            
                            cell.expenseBriefLabel.text = ("\(friendName) owes you $\(displayAmount) for \(expenseDescription)")
                            
                        } else {
                            
                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )
                            
                        }
                        
                    }
                    
                } else {
                    
                    if amount < 0 {

                        let displayAmount: String = "\(-amount)".currencyInputFormatting()

                        cell.expenseBriefLabel.text = ("\(friendName) owes you $\(displayAmount) for \(expenseDescription)")
                        
                    } else if amount == 0 {
                        
                        if paidBy == userUID {
                            
                            cell.expenseBriefLabel.text = ("You share nothing in this expense" )
                            
                        } else {

                            let displayAmount: String = "\(totalAmount)".currencyInputFormatting()
                            
                            cell.expenseBriefLabel.text = ("You owe \(friendName) $\(displayAmount) for \(expenseDescription)" )
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if isRead == true {
                
                cell.expenseBriefLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.expenseBriefLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
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

        guard
            let expenseID = expenseInfoList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "accepted", changeFriendStatus: nil)

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

        self.expenseListTableView.reloadData()

    }

    func touchDenyButton(sender: MyButton) {

        guard
            let expenseID = expenseInfoList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "sentDenied", changeFriendStatus: "denied")

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

        self.expenseListTableView.reloadData()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        Analytics.logEvent("clickExpenseDetailCell", parameters: nil)

        selectedRow = indexPath.row

        selectedSection = indexPath.section

            guard
                let expenseID = expenseInfoList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        self.performSegue(withIdentifier: "showExpenseDetailVC", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showExpenseDetailVC" {

            let destinationNC = segue.destination as? UINavigationController
            let destinationVC = destinationNC?.viewControllers.first as? ExpeneseDetailViewController

            switch expenseStatus {

            case .accepted:

                destinationVC?.expenseInformation = (expenseInfoList[friendUIDList[selectedSection]]?[selectedRow])!
                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.accepted.rawValue
                
            case .denied:
                
                destinationVC?.expenseInformation = (expenseInfoList[friendUIDList[selectedSection]]?[selectedRow])!
                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.denied.rawValue
                
            case .receivedPending:
                
                destinationVC?.expenseInformation = (expenseInfoList[friendUIDList[selectedSection]]?[selectedRow])!
                destinationVC?.isAcceptButtonHidden = false
                destinationVC?.isDenyButtonHidden = false
                destinationVC?.isDeleteButtonHidden = true
                destinationVC?.expenseStatus = ExpenseStatus.receivedPending.rawValue
                
            case .sentPending:
                
                destinationVC?.expenseInformation = (expenseInfoList[friendUIDList[selectedSection]]?[selectedRow])!
                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.sentPending.rawValue
                
            case .receivedDeleted:
                
                destinationVC?.expenseInformation = (expenseInfoList[friendUIDList[selectedSection]]?[selectedRow])!
                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = false
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.receivedDeleted.rawValue

            }
            
        }
        
    }

}
