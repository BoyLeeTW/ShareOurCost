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
import NVActivityIndicatorView

class FriendManager {

    var ref: DatabaseReference!

    func checkFriendID(userID: String, completion: @escaping ( (String, Bool, String) -> () )) {

        var userSelfID = String()

        ref = Database.database().reference()

        ref.child("userID").child(userUID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let userID = dataSnapshot.value as? String
                else { return }

            userSelfID = userID

        })

        ref.child("userID").queryOrderedByValue().queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            let object = dataSnapshot.value as? [String: Any]

            let pair = object?

                .filter({ (pair) -> Bool in
                    
                    let value = pair.value as? String
                
                    return value == userID
                
                })
                .first
            
            guard let searchedUID = pair?.key
                else {

                completion(userSelfID, dataSnapshot.exists(), "nothing")

                return

            }
            
            completion(userSelfID, dataSnapshot.exists(), searchedUID)

        })
        
    }

    func fetchUserInformation(searchedUID: String, completion: @escaping ( (String) -> () )) {

        ref = Database.database().reference()

        ref.child("userInfo").child(searchedUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let userName = dataSnapshot.value as? String
                else { return }

            completion(userName)

        })

    }

    //modify friend request status and friend list
    func handleFriendRequest(status: String) {

        ref = Database.database().reference()

        ref.child("userInfo").child("")

    }

    func fetchFriendUIDList(completion: @escaping ((Array<String>) -> ())) {

        ref = Database.database().reference()

        ref.child("userInfo").child(userUID).child("friendList").observe(.value, with: { (dataSnapshot) in

            var friendUIDListInClosure = [String]()
            
            guard let friendListData = dataSnapshot.value as? [String: Bool]
                else {

                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                return

            }

            for (friendID, _) in friendListData {

                friendUIDListInClosure.append(friendID)
            }

            completion(friendUIDListInClosure)
        })

    }

    func fetchFriendUIDtoNameList(friendUIDList: Array<String>, completion: @escaping ([String: String]) -> () ) {

        ref = Database.database().reference()

        var friendUIDtoNameList = [String: String]()

        for friendUID in friendUIDList {

            ref.child("userInfo").child(friendUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard let friendName = dataSnapshot.value as? String
                    else { return }

                friendUIDtoNameList[friendUID] = friendName

                DispatchQueue.main.async {
                 
                    completion(friendUIDtoNameList)
                    
                }

            })

        }

    }

    func searchFriendNameByUserID(userID: String, completion: @escaping ( (Bool ,String?, String?) -> () )) {

        ref = Database.database().reference()

        ref.child("userInfo").queryOrdered(byChild: "userID").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            if dataSnapshot.exists() == true {

                guard let searchedUserInfoOrigin = dataSnapshot.value as? [String: Any]
                    else { return }
                
                //key is userUID
                for (key, value) in searchedUserInfoOrigin {
                    
                    guard
                        let searchedUserInfo = value as? [String: Any],
                        let searchedUserName = searchedUserInfo["fullName"] as? String
                        else { return }
                    
                    completion(dataSnapshot.exists(), key, searchedUserName)

                }

            } else {

                completion(dataSnapshot.exists(), nil, nil)

            }

        })

    }

    func sendFriendRequest(friendUID: String) {

        ref.child("userInfo").child(friendUID).child("pendingFriendRequest").updateChildValues([userUID: false])
        
        ref.child("userInfo").child(userUID).child("pendingSentFriendRequest").updateChildValues([friendUID: false])

    }

    func fetchFriendNameAndUIDList(completion: @escaping () -> () ) {

        ref = Database.database().reference()

        for friendUID in friendUIDList {

        ref.child("userInfo").child(friendUID).child("fullName").observeSingleEvent(of: .value, with: { (dataSnapshot) in

            guard let friendName = dataSnapshot.value as? String
                else { return }

            friendNameAndUIDList.updateValue(friendUID, forKey: friendName)

            completion()

        })

        }
    }

    func fetchFriendList(friendUIDList: Array<String>) {

        ref = Database.database().reference()

        var friendInfoList = [Friend]()

        for friendUID in friendUIDList {
            
            ref.child("userInfo").child(friendUID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

                guard
                    let friendInfoListData = dataSnapshot.value as? [String: Any],
                    let friendName = friendInfoListData["fullName"] as? String,
                    let friendID = friendInfoListData["userID"] as? String
                    else { return }

                let friendInfo = Friend.init(firebaseUID: friendUID, Name: friendName, userID: friendID)

                friendInfoList.append(friendInfo)

            })
        }
    }

}
