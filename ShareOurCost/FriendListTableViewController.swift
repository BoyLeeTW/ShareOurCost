//
//  FriendListTableViewController.swift
//  ShareOurCost
//
//  Created by Brad on 30/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import NVActivityIndicatorView

class FriendListTableViewController: UITableViewController {

    @IBOutlet var friendListTableView: UITableView!

    var friendRequestIDList = [String]()

    var selectedRow = Int()

    var ref: DatabaseReference!

    let accountManager = AccountManager()

    let friendManager = FriendManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let activityData = ActivityData(message: "Loading...")

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)

        setUpNavigationBar()

        friendListTableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))

        friendManager.fetchFriendUIDList { [weak self] (friendUIDListOfBlock) in

            guard let weakSelf = self
                else { return }

            friendUIDList = friendUIDListOfBlock

            weakSelf.friendManager.fetchFriendUIDtoNameList(friendUIDList: friendUIDList, completion: { (friendUIDtoNameListOfBlock) in

                friendUIDandNameList = friendUIDtoNameListOfBlock

                weakSelf.friendListTableView.reloadData()

                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            })

        }

        ref = Database.database().reference()

        ref.child("userInfo").child(userUID).child("pendingFriendRequest").observe(.value, with: { (dataSnapshot) in

            guard let pendingFriendRequestList = dataSnapshot.value as? [String: Bool]
                else { return }

            for (friendUID, status) in pendingFriendRequestList where status == false {

                self.friendRequestIDList.append(friendUID)

            }

            //Need to reload data in this queue
            self.friendListTableView.reloadData()

        })

    }

    func setUpNavigationBar() {
        
        self.navigationController?.navigationBar.topItem?.title = "FRIEND"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18.0)!]

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-exit"), style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var sectionNameList = ["FRIENDS", "FRIEND REQUEST"]

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.bounds.size.width, height: 25))
        headerLabel.text = sectionNameList[section]
        headerLabel.font = UIFont(name: "Avenir-Medium", size: 16.0)
        headerLabel.textColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        
        headerView.addSubview(headerLabel)
        
        return headerView
        
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var sectionNameList = ["FRIENDS", "FRIEND REQUEST"]

        return sectionNameList[section]

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return friendUIDList.count

        case 1:
            return friendRequestIDList.count

        default:
            return 0
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section) {
        case 0:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as? FriendListTableViewCell
                else { return UITableViewCell() }

            guard let friendName = friendUIDandNameList[friendUIDList[indexPath.row]]
                else { return cell }

            cell.friendNameLabel.text = friendName

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestListCell", for: indexPath) as? FriendRequestListTableViewCell
                else { return UITableViewCell() }

            ref.child("userInfo").child(friendRequestIDList[indexPath.row]).child("fullName").observe(.value, with: { (dataSnapshot) in

                cell.friendNameLabel.text = dataSnapshot.value! as? String

            })

            cell.acceptFriendRequestButton.tag = indexPath.row

            cell.denyFriendRequestButton.tag = indexPath.row

            cell.acceptFriendRequestButton.addTarget(self, action: #selector(handleAcceptFriend), for: .touchUpInside)

            cell.denyFriendRequestButton.addTarget(self, action: #selector(handleDenyFriend), for: .touchUpInside)

            return cell

        }

    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestListCell", for: indexPath) as? FriendRequestListTableViewCell
            else { return }

        cell.friendNameLabel.text = ""

    }

    //change the status in the pendingFriendRequest and add friendID to friendList.
    func handleAcceptFriend(_ sender: UIButton) {

        Analytics.logEvent("acceptFriendRequest", parameters: nil)

        let friendID = friendRequestIDList[sender.tag]

        //add ID of user who sent friend request to receiver's friend list
        self.ref.database.reference().child("userInfo").child(userUID).child("friendList").updateChildValues([friendID: true])

        //add ID of user who accepted request to the user sent request friend list
        self.ref.database.reference().child("userInfo").child(friendID).child("friendList").updateChildValues([userUID: true])

        //change the pendingFriendRequest value of user who accepted request to true
        self.ref.database.reference().child("userInfo").child(userUID).child("pendingFriendRequest").updateChildValues([friendID: true])

        //change the pendingSentFriendRequest value of user who sent request to true
        self.ref.database.reference().child("userInfo").child(friendID).child("pendingSentFriendRequest").updateChildValues([userUID: true])

        friendRequestIDList.remove(at: sender.tag)

        self.friendListTableView.reloadData()

    }

    func handleDenyFriend(_ sender: UIButton) {

        Analytics.logEvent("clickDenyFriendRequest", parameters: nil)

        let friendID = friendRequestIDList[sender.tag]
        
        //change the pendingFriendRequest value of user who accepted request to true
        self.ref.database.reference().child("userInfo").child(userUID).child("pendingFriendRequest").updateChildValues([friendID: true])
        
        //change the pendingSentFriendRequest value of user who sent request to true
        self.ref.database.reference().child("userInfo").child(friendID).child("pendingSentFriendRequest").updateChildValues([userUID: true])

        self.friendListTableView.reloadData()
    }

    func handleLogout() {

        let alertController = UIAlertController(title: "Log Out",
                                                message: "Are you sure?",
                                                preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: .default, handler: { _ in

            self.accountManager.logOut()
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            
            self.present(loginVC!, animated: true)
            
            //clear log out user's data
            userUID = ""
            friendUIDandNameList = [String: String]()
            friendNameAndUIDList = [String: String]()
            friendUIDList = Array<String>()

            try? Auth.auth().signOut()

        })

        let cancelLogOutAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelLogOutAction)

        self.present(alertController, animated: true, completion:  nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowFriendDetailSegue" {

            let destinationVC = segue.destination as! FriendDetailListViewController

            destinationVC.friendUID = friendUIDList[selectedRow]

        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        Analytics.logEvent("clickFriendDetailCell", parameters: nil)

        selectedRow = indexPath.row

        performSegue(withIdentifier: "ShowFriendDetailSegue", sender: self)

    }

}
