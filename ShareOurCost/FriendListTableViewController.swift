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

    var friendRequestList = [String]()

    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(touchBackButton))

        ref = Database.database().reference()
        ref.child("userInfo").child((Auth.auth().currentUser?.uid)!).child("pendingFriendRequest").observe(.childAdded, with: { (dataSnapshot) in

            self.friendRequestList.append(dataSnapshot.key)
            print(self.friendRequestList)

            //Need to reload data in this queue
            self.friendListTableView.reloadData()
        })

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func touchBackButton() {

        self.dismiss(animated: true, completion: nil)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.friendRequestList.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as? FriendListTableViewCell else { return UITableViewCell() }

        ref.child("userInfo").child(friendRequestList[indexPath.row]).child("fullName").observe(.value, with: { (dataSnapshot) in

            print(dataSnapshot.value!)

            cell.friendNameLabel.text = dataSnapshot.value! as? String

        })

        cell.acceptFriendRequestButton.tag = indexPath.row

        cell.denyFriendRequestButton.tag = indexPath.row

        cell.acceptFriendRequestButton.addTarget(self, action: #selector(handleAcceptFriend), for: .touchUpInside)

        cell.denyFriendRequestButton.addTarget(self, action: #selector(handleDenyFriend), for: .touchUpInside)

        return cell
    }

    //change the status in the pendingFriendRequest and add friendID to friendList.
    func handleAcceptFriend(_ sender: UIButton) {

        let friendID = friendRequestList[sender.tag]
        print(friendID)

        ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("pendingFriendRequest").child("\(friendID)").observe(.value, with: { (dataSnapshot) in
            print(dataSnapshot)

            //add ID of user who sent friend request to receiver's friend list
            self.ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("friendList").updateChildValues([friendID: true])

            //add ID of user who accepted request to the user sent request friend list
            self.ref.database.reference().child("userInfo").child(friendID).child("friendList").updateChildValues([Auth.auth().currentUser!.uid: true])

            //change the pendingFriendRequest value of user who accepted request to true
            self.ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("pendingFriendRequest").updateChildValues([friendID: true])

            //change the pendingSentFriendRequest value of user who sent request to true
            self.ref.database.reference().child("userInfo").child(friendID).child("pendingSentFriendRequest").updateChildValues([Auth.auth().currentUser!.uid: true])

        })

    }

    //NOT FINISH YET
    func handleDenyFriend(_ sender: UIButton) {

        let friendID = friendRequestList[sender.tag]
        ref.database.reference().child("userInfo").child(Auth.auth().currentUser!.uid).child("pendingFriendRequest").child("\(friendID)").observe(.value, with: { (dataSnapshot) in
            print(dataSnapshot)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
