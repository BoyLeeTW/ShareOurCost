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

    func firebaseSignIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
            if error == nil {
                    
                print("Successful logged in!")
                    
                print(user!.uid)
                    
                UserDefaults.standard.setValue(user!.uid, forKey: "userUid")

            } else {

                print(error?.localizedDescription as Any)

            }

        }

    }

    func checkIfUserIDUnique(userID: String) -> Bool {

        ref = Database.database().reference()

        //check if userID is unique

        var result = Bool()

        ref.child("userID").queryOrderedByValue().queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (dataSnapshot) in

            if dataSnapshot.exists() {

                result = false

            } else {

                result = true

            }

        })

        return result

    }

    func firebaseRigistration(email: String, password: String, userName: String, userID: String) {

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            if error == nil {
                print("Successful signed up!")

                self.ref?.child("userInfo").child("\(user!.uid)").setValue(
                    ["email": "\(email)",
                        "fullName": "\(userName)",
                        "userID": "\(userID)",
                        "createdTime": (Date().timeIntervalSince1970)
                    ])
                
                self.ref?.child("userID").updateChildValues(["\(user!.uid)": "\(userID)"])

            }
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

}
