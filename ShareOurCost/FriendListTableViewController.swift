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

class FriendListTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    @IBOutlet var friendListTableView: UITableView!
    @IBAction func touchAcceptFriendButton(_ sender: Any) {
    }

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

        friendManager.fetchFriendUIDList { (friendUIDListOfBlock) in

            friendUIDList = friendUIDListOfBlock

            self.friendManager.fetchFriendUIDtoNameList(friendUIDList: friendUIDList, completion: { (friendUIDtoNameListOfBlock) in

                friendUIDandNameList = friendUIDtoNameListOfBlock

                self.friendListTableView.reloadData()

                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            })

        }

        ref = Database.database().reference()

        ref.child("userInfo").child(userUID).child("pendingFriendRequest").observe(.childAdded, with: { (dataSnapshot) in

            if let friendRequestStatus = dataSnapshot.value! as? Bool {

                if friendRequestStatus == false {

                    self.friendRequestIDList.append(dataSnapshot.key)

                }

            }

            //Need to reload data in this queue
            self.friendListTableView.reloadData()

        })

    }

    func setUpNavigationBar() {
        
        self.navigationController?.navigationBar.topItem?.title = "Friend"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-exit"), style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var sections = ["Your Friends", "Friend Request"]

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.bounds.size.width, height: 25))
        headerLabel.text = sections[section]
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.textColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        
        headerView.addSubview(headerLabel)
        
        return headerView
        
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var sections = ["Your Friends", "Friend Request"]

        return sections[section]

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

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as? FriendListTableViewCell else { return UITableViewCell() }

            guard let friendName = friendUIDandNameList[friendUIDList[indexPath.row]] else { return cell }

            cell.friendNameLabel.text = friendName

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestListCell", for: indexPath) as? FriendRequestListTableViewCell else { return UITableViewCell() }

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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestListCell", for: indexPath) as? FriendRequestListTableViewCell else { return }

        cell.friendNameLabel.text = ""
        

    }

    //change the status in the pendingFriendRequest and add friendID to friendList.
    func handleAcceptFriend(_ sender: UIButton) {

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

    //NOT FINISH YET
    func handleDenyFriend(_ sender: UIButton) {

        let friendID = friendRequestIDList[sender.tag]
        ref.database.reference().child("userInfo").child(userUID).child("pendingFriendRequest").child("\(friendID)").observe(.value, with: { (dataSnapshot) in
        })

    }

    func handleLogout() {

        accountManager.logOut()

        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        
        self.present(loginVC!, animated: true)

        //clear log out user's data
        userUID = ""
        friendUIDandNameList = [String: String]()
        friendNameAndUIDList = [String: String]()
        friendUIDList = Array<String>()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowFriendDetailSegue" {

            let destinationVC = segue.destination as! FriendDetailListViewController

            destinationVC.friendUID = friendUIDList[selectedRow]

        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedRow = indexPath.row

        performSegue(withIdentifier: "ShowFriendDetailSegue", sender: self)

    }

}
