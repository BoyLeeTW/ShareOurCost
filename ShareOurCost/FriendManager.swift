//
//  FriendManager.swift
//  ShareOurCost
//
//  Created by Brad on 06/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FriendManager {

    var ref: DatabaseReference!

    func checkFriendID(userID: String, completion: @escaping ( (String, Bool, String) -> () )) {

        var userSelfID = String()

        ref = Database.database().reference()

        ref.child("userID").child(userUID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let userID = dataSnapshot.value as? String else { return }

            userSelfID = userID

            self.ref.child("userID").child(userUID).removeAllObservers()

        })

        ref.child("userID").queryOrderedByValue().queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            let object = dataSnapshot.value as? [String: Any]

            let pair = object?

                .filter({ (pair) -> Bool in
                    
                    let value = pair.value as? String
                
                    return value == userID
                
                })
                .first
            
            guard let searchedUID = pair?.key else {

                completion(userSelfID, dataSnapshot.exists(), "nothing")

                return }
            
            completion(userSelfID, dataSnapshot.exists(), searchedUID)

            self.ref.child("userID").removeAllObservers()

        })
        
    }

    func fetchUserInformation(searchedUID: String, completion: @escaping ( (String) -> () )) {

        ref = Database.database().reference()

        ref.child("userInfo").child(searchedUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let userName = dataSnapshot.value as? String else { return }

            completion(userName)

        })

    }

    //modify friend request status and friend list
    func handleFriendRequest(status: String) {

        ref = Database.database().reference()

        ref.child("userInfo").child("")

    }

    func fetchFriendUIDList(completion: @escaping ((Array<String>) -> ())) {

        var friendUIDList = [String]()

        ref = Database.database().reference()

        ref.child("userInfo").child(userUID).child("friendList").observe(.value, with: { (dataSnapshot) in

            guard let friendListData = dataSnapshot.value as?[String: Bool] else { return }

            for (friendID, _) in friendListData {

                friendUIDList.append(friendID)
            }

            completion(friendUIDList)
        })

    }

    func fetchFriendUIDtoNameList(friendUIDList: Array<String>, completion: @escaping ([String: String]) -> () ) {

        ref = Database.database().reference()

        var friendUIDtoNameList = [String: String]()

        for friendUID in friendUIDList {

            ref.child("userInfo").child(friendUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard let friendName = dataSnapshot.value as? String else { return }

                friendUIDtoNameList[friendUID] = friendName

                DispatchQueue.main.async {
                 
                    completion(friendUIDtoNameList)
                    
                }

            })

        }

    }

}
