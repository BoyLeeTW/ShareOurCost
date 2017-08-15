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

class FriendListTableViewController: UITableViewController {
    @IBOutlet var friendListTableView: UITableView!
    @IBAction func touchAcceptFriendButton(_ sender: Any) {
    }

    var friendRequestIDList = [String]()

    var friendIDList = [String]()

    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        ref.child("userInfo").child((Auth.auth().currentUser?.uid)!).child("pendingFriendRequest").observe(.childAdded, with: { (dataSnapshot) in

            if let friendRequestStatus = dataSnapshot.value! as? Bool {

                if friendRequestStatus == false {

                    self.friendRequestIDList.append(dataSnapshot.key)

                }

            }

            //Need to reload data in this queue
            self.friendListTableView.reloadData()

        })

        ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("friendList").observe(.childAdded, with: { (dataSnapshot) in

            self.friendIDList.append(dataSnapshot.key)

            self.friendListTableView.reloadData()

        })

    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var sections = ["Your Friends", "Friend Request"]

        return sections[section]

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return friendIDList.count

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

            ref.child("userInfo").child(friendIDList[indexPath.row]).child("fullName").observe(.value, with: { (dataSnapshot) in

                cell.friendNameLabel.text = dataSnapshot.value! as? String

            })

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

    //change the status in the pendingFriendRequest and add friendID to friendList.
    func handleAcceptFriend(_ sender: UIButton) {

        let friendID = friendRequestIDList[sender.tag]

        //add ID of user who sent friend request to receiver's friend list
        self.ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("friendList").updateChildValues([friendID: true])

        //add ID of user who accepted request to the user sent request friend list
        self.ref.database.reference().child("userInfo").child(friendID).child("friendList").updateChildValues([Auth.auth().currentUser!.uid: true])

        //change the pendingFriendRequest value of user who accepted request to true
        self.ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("pendingFriendRequest").updateChildValues([friendID: true])

        //change the pendingSentFriendRequest value of user who sent request to true
        self.ref.database.reference().child("userInfo").child(friendID).child("pendingSentFriendRequest").updateChildValues([Auth.auth().currentUser!.uid: true])

        friendRequestIDList.remove(at: sender.tag)

        self.friendListTableView.reloadData()

    }

    //NOT FINISH YET
    func handleDenyFriend(_ sender: UIButton) {

        let friendID = friendRequestIDList[sender.tag]
        ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("pendingFriendRequest").child("\(friendID)").observe(.value, with: { (dataSnapshot) in
        })

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
