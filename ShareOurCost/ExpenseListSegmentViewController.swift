//
//  ExpenseListSegmentViewController.swift
//  ShareOurCost
//
//  Created by Brad on 11/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class ExpenseListSegmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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

    var receivedDeletedExpenseIDList = ExpenseIDList()

    var selectedRow = Int()

    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()

        setUpSegmentController()

        setUpNavigationBar()

        expenseManager.fetchAcceptedExpenseList { (acceptedExpenseList) in

        }

    }

    override func viewWillAppear(_ animated: Bool) {

        self.expenseListTableView.reloadData()

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
                
                self.expenseManager.newFetchExpenseIDList { (acceptedExpenseIDList, receivedPendingExpenseIDList, sentPendingExpenseIDList, deniedExpenseIDList, receivedDeletedExpenseIDList) in
                    
                    self.acceptedExpenseIDList = acceptedExpenseIDList
                    self.receivedPendingExpenseIDList = receivedPendingExpenseIDList
                    self.sentPendingExpenseIDList = sentPendingExpenseIDList
                    self.deniedExpenseIDList = deniedExpenseIDList
                    self.receivedDeletedExpenseIDList = receivedDeletedExpenseIDList

                    self.expenseListTableView.reloadData()
                    
                }
            }
        }
    }

    func setUpNavigationBar() {

        self.navigationController?.navigationBar.topItem?.title = "Shared Expense"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }

    func setUpSegmentController() {

        expenseStatusSegmentController.addTarget(self, action: #selector(expenseStatusSegmentControllerChanged), for: .valueChanged)

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    func expenseStatusSegmentControllerChanged() {

        expenseListTableView.reloadData()

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor.white

        let headerLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.bounds.size.width, height: 25))
        headerLabel.text = friendUIDtoNameList[friendUIDList[section]]
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.textColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)

        headerView.addSubview(headerLabel)
        
        return headerView

    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }

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

        case 2:

            rowInSection = receivedPendingExpenseIDList[friendUIDList[section]]?.count ?? 0

        case 3:

            rowInSection = sentPendingExpenseIDList[friendUIDList[section]]?.count ?? 0

        case 1:

            rowInSection = deniedExpenseIDList[friendUIDList[section]]?.count ?? 0

        default:

            rowInSection = receivedDeletedExpenseIDList[friendUIDList[section]]?.count ?? 0

        }

        return rowInSection

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseListSegmentCell", for: indexPath) as! ExpenseListSegmentTableViewCell

        switch expenseStatusSegmentController.selectedSegmentIndex {
        case 0:

            guard let expenseData = acceptedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                  let expenseDescription = expenseData["description"] as? String,
                  let expenseDate = expenseData["expenseDay"] as? String,
                  let sharedResult = expenseData["sharedResult"] as? [String: Int],
                  let isRead = expenseData["isRead"] as? Bool,
                  let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]

            else { return cell }

            if isRead == true {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.expenseCreatedDateLabel.text = expenseDate
            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        case 2:

        guard let expenseData = receivedPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
            let expenseDescription = expenseData["description"] as? String,
            let expenseDate = expenseData["expenseDay"] as? String,
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

        case 3:

            guard let expenseData = sentPendingExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                let expenseDate = expenseData["expenseDay"] as? String,
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }

            if isRead == true {
                
                cell.contentView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.contentView.backgroundColor = UIColor.black
                
            }
            
            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.expenseCreatedDateLabel.text = expenseDate
            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        case 1:

            guard let expenseData = deniedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                let expenseDate = expenseData["expenseDay"] as? String,
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }
            
            if isRead == true {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.expenseCreatedDateLabel.text = expenseDate
            cell.acceptButton.isHidden = true
            cell.denyButton.isHidden = true

        default:

            guard let expenseData = receivedDeletedExpenseIDList[friendUIDList[indexPath.section]]?[indexPath.row],
                let expenseDate = expenseData["expenseDay"] as? String,
                let expenseDescription = expenseData["description"] as? String,
                let sharedResult = expenseData["sharedResult"] as? [String: Int],
                let isRead = expenseData["isRead"] as? Bool,
                let friendName = friendUIDtoNameList[friendUIDList[indexPath.section]]
                
                else { return cell }
            
            if isRead == true {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0)
                
            } else {
                
                cell.friendNameLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
                cell.expenseCreatedDateLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
            }

            for (key, value) in sharedResult where value < 0 {
                
                if key == userUID {
                    
                    cell.friendNameLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                    
                } else {
                    
                    cell.friendNameLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                    
                }
                
            }

            cell.expenseCreatedDateLabel.text = expenseDate
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

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "accepted", changeFriendStatus: nil)

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

        self.expenseListTableView.reloadData()

    }

    func touchDenyButton(sender: MyButton) {

        guard let expenseID = receivedPendingExpenseIDList[friendUIDList[sender.section!]]![sender.row!]["id"] as? String,
            let friendUID = friendUIDList[sender.section!] as? String
            else { return }

        expenseManager.changeExpenseStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: "denied", changeFriendStatus: nil)

        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: false)

        self.expenseListTableView.reloadData()

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

        case 2:

            guard let expenseID = receivedPendingExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)


        case 3:

            guard let expenseID = sentPendingExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)


        case 1:

            guard let expenseID = deniedExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
                let friendUID = friendUIDList[selectedSection] as? String
                else { return }
            
            expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        default:

            guard let expenseID = receivedDeletedExpenseIDList[friendUIDList[selectedSection]]![selectedRow]["id"] as? String,
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

                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.accepted.rawValue

            case 2:

                destinationVC?.expenseInformation = (receivedPendingExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

                destinationVC?.isAcceptButtonHidden = false
                destinationVC?.isDenyButtonHidden = false
                destinationVC?.isDeleteButtonHidden = true
                destinationVC?.expenseStatus = ExpenseStatus.receivedPending.rawValue

            case 3:

                destinationVC?.expenseInformation = (sentPendingExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.sentPending.rawValue

            case 1:

                destinationVC?.expenseInformation = (deniedExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.denied.rawValue

            default:

                destinationVC?.expenseInformation = (receivedDeletedExpenseIDList[friendUIDList[selectedSection]]?[selectedRow])!

                destinationVC?.isAcceptButtonHidden = true
                destinationVC?.isDenyButtonHidden = true
                destinationVC?.isDeleteButtonHidden = false
                destinationVC?.expenseStatus = ExpenseStatus.receivedDeleted.rawValue

            }

        }

    }

}
