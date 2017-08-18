//
//  LoginManager.swift
//  ShareOurCost
//
//  Created by Brad on 05/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AccountManager {

    var ref: DatabaseReference!

    func firebaseSignIn(email: String, password: String, completion: @escaping ((Bool, Error?) -> ())) {

        var loginResult = false

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
            if error == nil {

                loginResult = true

                UserDefaults.standard.setValue(user!.uid, forKey: "userUid")

                userUID = Auth.auth().currentUser!.uid

                completion(loginResult, nil)

            } else {

                completion(loginResult, error)

            }

        }

    }

    func checkIfUserIDUnique(userID: String, completion:  @escaping ((Bool) -> ())) {

        ref = Database.database().reference()

        //check if userID is unique
        
        ref.child("userID").queryOrderedByValue().queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            completion(!dataSnapshot.exists())
        })

    }

    func firebaseRegistration(email: String, password: String, userName: String, userID: String) {

        ref = Database.database().reference()

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            if error == nil {
                print("Successful signed up!")

                userUID = Auth.auth().currentUser!.uid

                self.ref?.child("userInfo").child("\(user!.uid)").setValue(
                    ["email": "\(email)",
                        "fullName": "\(userName)",
                        "userID": "\(userID)",
                        "createdTime": (Date().timeIntervalSince1970)
                    ])

                self.ref.child("userID").updateChildValues(["\(user!.uid)": "\(userID)"])

            } else {

                print("sonething went wrong!")

            }

            userUID = Auth.auth().currentUser!.uid

        }
    }

    func firebaseResetPassword(email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { ( error ) in

            if let error = error {

                print(error.localizedDescription)

            } else {

                print("Sent password reset mail successfully!")

            }

        }

    }

    func logOut() {
        
        UserDefaults.standard.setValue(nil, forKey: "userUid")
        
    }

}
