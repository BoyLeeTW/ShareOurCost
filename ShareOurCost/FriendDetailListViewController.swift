//
//  FriendDetailListViewController.swift
//  ShareOurCost
//
//  Created by Brad on 15/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class FriendDetailListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var friendDetailExpenseListTableView: UITableView!

    var friendUID = String()

    let expenseManager = ExpenseManager()

    var acceptedExpenseList = [String: [[String: Any]]]()

    var balanceToFriend = Int()

    var existingExpenseIDList = Array<String>()

    var selectedRow = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAcceptedExpenseData()

        setUpNavigationBar()

        setUpLayOut()

        setUpGesture()

        friendDetailExpenseListTableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))

    }

    func fetchAcceptedExpenseData() {

        let activityData = ActivityData(message: "Loading...")

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)

        expenseManager.fetchAcceptedExpenseList { [weak self] (acceptedExepnseList) in

            guard let weakSelf = self else { return }

            weakSelf.acceptedExpenseList = acceptedExepnseList

            weakSelf.friendDetailExpenseListTableView.reloadData()

            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            guard let expenseInfoSource = acceptedExepnseList[weakSelf.friendUID]

            else { weakSelf.balanceLabel.text = "There is no expense yet!"
                
                return

            }
            
            for expenseInfo in expenseInfoSource {
                
                guard let sharedResult = expenseInfo["sharedResult"] as? [String: Int],
                      let expenseID = expenseInfo["id"] as? String,
                      let friendName = friendUIDandNameList[weakSelf.friendUID]
                else { return }
                
                if weakSelf.existingExpenseIDList.contains(expenseID) {
                    
                    continue
                    
                } else {
                    
                    weakSelf.existingExpenseIDList.append(expenseID)
                }
                
                for (key, value) in sharedResult where value < 0 {
                    
                    //you own friend money
                    if key == userUID {
                        
                        weakSelf.balanceToFriend += value
                        
                        // friend owes you money
                    } else {
                        
                        weakSelf.balanceToFriend -= value
                        
                    }
                    
                }
                
                if weakSelf.balanceToFriend < 0 {
                    
                    weakSelf.balanceLabel.text = "You owe \(friendName) $" + "\(abs(weakSelf.balanceToFriend))".currencyInputFormatting()
                    
                } else {
                    
                    weakSelf.balanceLabel.text = "\(friendName) owes you $" + "\(abs(weakSelf.balanceToFriend))".currencyInputFormatting()
                    
                }
                
            }
            
        }

        self.balanceLabel.text = "There is no expense yet!"

    }

    func setUpLayOut() {

        self.balanceLabel.layer.borderWidth = 4
        self.balanceLabel.layer.borderColor = UIColor.white.cgColor

    }

    func setUpNavigationBar() {

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_navigate_before_white_36pt"), style: .plain, target: self, action: #selector(touchBackButton))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

    }

    func touchBackButton() {

        self.navigationController?.popViewController(animated: true)

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let numberOfRowsInSectionList = acceptedExpenseList[self.friendUID] else { return 0 }

        return numberOfRowsInSectionList.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendDetailListCell", for: indexPath) as! FriendDetailListTableViewCell

        guard let expenseData = acceptedExpenseList[friendUID]?[indexPath.row],
            let expenseDescription = expenseData["description"] as? String,
            let sharedResult = expenseData["sharedResult"] as? [String: Int],
            let isRead = expenseData["isRead"] as? Bool,
            let expenseDate = expenseData["expenseDay"] as? String,
            let friendName = friendUIDandNameList[friendUID]
            
            else { return cell }
        
        if isRead == true {
            
            cell.expenseDescriptionLabel.font = UIFont.systemFont(ofSize: 15.0)
            cell.expenseDateLabel.font = UIFont.systemFont(ofSize: 10.0)
            
        } else {
            
            cell.expenseDescriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: 1)
            cell.expenseDateLabel.font = UIFont.systemFont(ofSize: 10.0, weight: 1)
        }
        
        for (key, value) in sharedResult where value < 0 {
            
            if key == userUID {
                
                cell.expenseDescriptionLabel.text = ("You owe \(friendName) $\(-value) for \(expenseDescription)" )
                
            } else {
                
                cell.expenseDescriptionLabel.text = ("\(friendName) owes you $\(-value) for \(expenseDescription)")
                
            }
            
        }

        cell.expenseDateLabel.text = expenseDate

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        Analytics.logEvent("clickExpenseDetailFromFriendDetailPage", parameters: nil)

        selectedRow = indexPath.row

        tableView.deselectRow(at: indexPath, animated: true)

        guard let expenseID = acceptedExpenseList[friendUID]![indexPath.row]["id"] as? String
            else { return }
        
        expenseManager.changeExpenseReadStatus(friendUID: friendUID, expenseID: expenseID, changeSelfStatus: true, changeFriendStatus: nil)

        self.performSegue(withIdentifier: "showExpenseDetailVC", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showExpenseDetailVC" {

            let destinationNC = segue.destination as? UINavigationController
            let destinationVC = destinationNC?.viewControllers.first as? ExpeneseDetailViewController

            destinationVC?.expenseInformation = (self.acceptedExpenseList[friendUID]?[selectedRow])!
            
            destinationVC?.isAcceptButtonHidden = true
            destinationVC?.isDenyButtonHidden = true
            destinationVC?.isDeleteButtonHidden = false
            destinationVC?.expenseStatus = ExpenseStatus.accepted.rawValue

        }
    }

    func setUpGesture() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.navigationController?.popViewController(animated: true)
            
        }
    }
}
