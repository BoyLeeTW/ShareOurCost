//
//  ExpenseListViewController.swift
//  ShareOurCost
//
//  Created by Brad on 26/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import PageMenu
import NVActivityIndicatorView

class ExpenseListViewController: UIViewController {

    var pageMenu : CAPSPageMenu?
    
    var acceptedExpenseListTVC = ExpenseSegmentedTableViewController()
    
    var deniedExpenseListTVC = ExpenseSegmentedTableViewController()

    var receivedPendingExpenseListTVC = ExpenseSegmentedTableViewController()

    var sentPendingExpenseListTVC = ExpenseSegmentedTableViewController()

    var receivedDeletedExepsneListTVC = ExpenseSegmentedTableViewController()

    typealias ExpenseIDList = [String: [[String: Any]]]
    
    var friendManager = FriendManager()
    
    var expenseManager = ExpenseManager()
    
    var friendUIDList = [String]()
    
    var friendUIDtoNameList = [String: String]()

    var selectedRow = Int()
    
    var selectedSection = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        acceptedExpenseListTVC = storyboard.instantiateViewController(withIdentifier: "ExpenseSegmentTVC") as! ExpenseSegmentedTableViewController
        
        deniedExpenseListTVC = storyboard.instantiateViewController(withIdentifier: "ExpenseSegmentTVC") as! ExpenseSegmentedTableViewController

        receivedPendingExpenseListTVC = storyboard.instantiateViewController(withIdentifier: "ExpenseSegmentTVC") as! ExpenseSegmentedTableViewController

        sentPendingExpenseListTVC = storyboard.instantiateViewController(withIdentifier: "ExpenseSegmentTVC") as! ExpenseSegmentedTableViewController

        receivedDeletedExepsneListTVC = storyboard.instantiateViewController(withIdentifier: "ExpenseSegmentTVC") as! ExpenseSegmentedTableViewController

        fetchData()

        setUpNavigationBar()

        setupPages()

    }

    func fetchData() {
        
        let activityData = ActivityData(message: "Loading...")
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DispatchQueue.global().async {
            
            self.friendManager.fetchFriendUIDList { [weak self] (friendUIDList) in
                
                guard let weakSelf = self else { return }

                weakSelf.acceptedExpenseListTVC.friendUIDList = friendUIDList

                weakSelf.deniedExpenseListTVC.friendUIDList = friendUIDList

                weakSelf.receivedPendingExpenseListTVC.friendUIDList = friendUIDList

                weakSelf.sentPendingExpenseListTVC.friendUIDList = friendUIDList

                weakSelf.receivedDeletedExepsneListTVC.friendUIDList = friendUIDList

                weakSelf.friendUIDList = friendUIDList
                
                weakSelf.friendManager.fetchFriendList(friendUIDList: weakSelf.friendUIDList)
                
                weakSelf.friendManager.fetchFriendUIDtoNameList(friendUIDList: weakSelf.friendUIDList, completion: { (friendUIDtoNameList) in
                    
                    friendUIDandNameList = friendUIDtoNameList
                    
                    weakSelf.friendUIDtoNameList = friendUIDtoNameList

                    weakSelf.acceptedExpenseListTVC.friendUIDtoNameList = friendUIDtoNameList
                    weakSelf.deniedExpenseListTVC.friendUIDtoNameList = friendUIDtoNameList
                    weakSelf.receivedPendingExpenseListTVC.friendUIDtoNameList = friendUIDtoNameList
                    weakSelf.sentPendingExpenseListTVC.friendUIDtoNameList = friendUIDtoNameList
                    weakSelf.receivedDeletedExepsneListTVC.friendUIDtoNameList = friendUIDtoNameList

                    weakSelf.acceptedExpenseListTVC.expenseStatus = .accepted
                    weakSelf.deniedExpenseListTVC.expenseStatus = .denied
                    weakSelf.receivedPendingExpenseListTVC.expenseStatus = .receivedPending
                    weakSelf.sentPendingExpenseListTVC.expenseStatus = .sentPending
                    weakSelf.receivedDeletedExepsneListTVC.expenseStatus = .receivedDeleted

                    weakSelf.acceptedExpenseListTVC.tableView.reloadData()
                    weakSelf.deniedExpenseListTVC.tableView.reloadData()
                    weakSelf.receivedDeletedExepsneListTVC.tableView.reloadData()
                    weakSelf.sentPendingExpenseListTVC.tableView.reloadData()
                    weakSelf.receivedDeletedExepsneListTVC.tableView.reloadData()
                    
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    
                })
                
                weakSelf.expenseManager.newFetchExpenseIDList { (acceptedExpenseIDList, receivedPendingExpenseIDList, sentPendingExpenseIDList, deniedExpenseIDList, receivedDeletedExpenseIDList) in

                    weakSelf.acceptedExpenseListTVC.expenseInfoList = acceptedExpenseIDList
                    weakSelf.deniedExpenseListTVC.expenseInfoList = deniedExpenseIDList
                    weakSelf.receivedPendingExpenseListTVC.expenseInfoList = receivedPendingExpenseIDList
                    weakSelf.sentPendingExpenseListTVC.expenseInfoList = sentPendingExpenseIDList
                    weakSelf.receivedDeletedExepsneListTVC.expenseInfoList = receivedDeletedExpenseIDList

                    weakSelf.acceptedExpenseListTVC.expenseStatus = .accepted
                    weakSelf.deniedExpenseListTVC.expenseStatus = .denied
                    weakSelf.receivedPendingExpenseListTVC.expenseStatus = .receivedPending
                    weakSelf.sentPendingExpenseListTVC.expenseStatus = .sentPending
                    weakSelf.receivedDeletedExepsneListTVC.expenseStatus = .receivedDeleted

                    weakSelf.acceptedExpenseListTVC.tableView.reloadData()
                    weakSelf.deniedExpenseListTVC.tableView.reloadData()
                    weakSelf.receivedDeletedExepsneListTVC.tableView.reloadData()
                    weakSelf.sentPendingExpenseListTVC.tableView.reloadData()
                    weakSelf.receivedDeletedExepsneListTVC.tableView.reloadData()

                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    
                }
            }
        }
    }
    
    func setUpNavigationBar() {
        
        self.navigationController?.navigationBar.topItem?.title = "SHARED EXPENSE"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18.0)!]
        
    }

    func setupPages() {
        
        var controllerArray: [UIViewController] = []
        
        acceptedExpenseListTVC.title = "ACCEPTED"
        
        deniedExpenseListTVC.title = "DENIED"
        
        receivedPendingExpenseListTVC.title = "RECIEVED"

        sentPendingExpenseListTVC.title = "SENT"

        receivedDeletedExepsneListTVC.title = "DELETE?"

        controllerArray.append(acceptedExpenseListTVC)
        controllerArray.append(deniedExpenseListTVC)
        controllerArray.append(receivedPendingExpenseListTVC)
        controllerArray.append(sentPendingExpenseListTVC)
        controllerArray.append(receivedDeletedExepsneListTVC)

        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.clear),
            .viewBackgroundColor(UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor.clear),
            .selectionIndicatorColor(UIColor.white),
            .selectionIndicatorHeight(5),
            .menuMargin(5.0),
            .menuHeight(25.0),
            .menuItemWidth(90),
            .menuItemFont(UIFont(name: "Avenir-Medium", size: 14.0)!),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor.white),
            .useMenuLikeSegmentedControl(false),
            .selectionIndicatorHeight(5.0),
            .menuItemSeparatorWidth(0.0),
            .menuItemSeparatorPercentageHeight(0.0)
        ]

        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height
        )

        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: frame, pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
        
    }

}
