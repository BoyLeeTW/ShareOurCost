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
import NVActivityIndicatorView

class AccountManager {

    var ref: DatabaseReference!

    func firebaseSignIn(email: String, password: String, completion: @escaping ((Bool, Error?) -> ())) {

        var loginResult = false

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in

            Analytics.logEvent("login", parameters: nil)

            if error == nil {

                Analytics.logEvent("loginSuccessfully", parameters: nil)

                loginResult = true

                UserDefaults.standard.setValue(user!.uid, forKey: "userUid")

                userUID = Auth.auth().currentUser!.uid

                completion(loginResult, nil)

            } else {

                Analytics.logEvent("loginFailed", parameters: nil)
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

    func firebaseRegistration(email: String, password: String, userName: String, userID: String, completion:
        @escaping (String?) -> ()) {

        ref = Database.database().reference()

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            if error == nil {

                Analytics.logEvent("regiterSuccessfully", parameters: nil)

                userUID = Auth.auth().currentUser!.uid

                self.ref?.child("userInfo").child("\(user!.uid)").setValue(
                    ["email": "\(email)",
                        "fullName": "\(userName)",
                        "userID": "\(userID)",
                        "createdTime": (Date().timeIntervalSince1970)
                    ])

                self.ref.child("userID").updateChildValues(["\(user!.uid)": "\(userID)"])

                userUID = Auth.auth().currentUser!.uid

                completion(nil)

            } else {

                Analytics.logEvent("registerFailed", parameters: nil)

                completion(error?.localizedDescription)

            }

        }
    }

    func firebaseResetPassword(email: String) {

        Analytics.logEvent("clickResetPassword", parameters: nil)

        Auth.auth().sendPasswordReset(withEmail: email) { ( error ) in

            if error != nil {

            } else {

            }

        }

    }

    func logOut() {

        UserDefaults.standard.setValue(nil, forKey: "userUid")

        Analytics.logEvent("clickLogOut", parameters: nil)

        do {

           try Auth.auth().signOut()

        }

        catch {

            print("Something went wrong with sign out!")

        }

    }

}
