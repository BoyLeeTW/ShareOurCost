//
//  ViewController.swift
//  ShareOurCost
//
//  Created by Brad on 25/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

// TO DO: Add user's account create time

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var signInOrRegisterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signInOrUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var userIDTextField: UITextField!

    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameTextField.isHidden = true

        userIDTextField.isHidden = true

        signInOrRegisterSegmentedControl.addTarget(self, action: #selector(handleSignInOrRegisterChange), for: UIControlEvents.valueChanged)

        ref = Database.database().reference()

        signInOrUpButton.addTarget(self, action: #selector(handleSignInOrRegister), for: .touchUpInside)

        forgetPasswordButton.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)

        ref.child("userID").observe(.childAdded, with: { (dataSnapshot) in
            print(dataSnapshot.value!)
        })

    }

    func handleSignInOrRegisterChange() {

        if signInOrRegisterSegmentedControl.selectedSegmentIndex == 1 {

            signInOrUpButton.setTitle("Register", for: .normal)

            fullNameTextField.isHidden = false

            userIDTextField.isHidden = false

            forgetPasswordButton.isHidden = true

        } else {

            signInOrUpButton.setTitle("Sign In", for: .normal)

            fullNameTextField.isHidden = true

            userIDTextField.isHidden = true

            forgetPasswordButton.isHidden = false

        }

    }

    func handleSignInOrRegister() {

        if signInOrRegisterSegmentedControl.selectedSegmentIndex == 0 {

            handleSignIn()

        } else {

            handleRegistration()

        }

    }

    func handleSignIn() {

        if emailTextField.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Please enter email account", preferredStyle: .alert)

            //what is handler
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            present(alertController, animated: true, completion: nil)

        } else {

            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in

                if error == nil {

                    print("Successful logged in!")

                    print(user!.uid)

                    UserDefaults.standard.setValue(user!.uid, forKey: "userUid")

                    print(UserDefaults.standard.value(forKey: "userUid"))

                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MatchingVC")
                    self.present(vc!, animated: true, completion: nil)

                    // MARK: save uid

                } else {

                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func handleRegistration() {

        if emailTextField.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Enter an email address!", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion:  nil)

        } else {

            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in

                if error == nil {
                    print("Successful signed up!")

                    self.ref?.child("userInfo").child("\(user!.uid)").setValue(
                        ["email": "\(self.emailTextField.text!)",
                            "fullName": "\(self.fullNameTextField.text!)",
                            "userID": "\(self.userIDTextField.text!)",
                            "createdTime": (Date().timeIntervalSince1970)
                        ])
                    self.ref?.child("userID").updateChildValues(["\(user!.uid)": "\(self.userIDTextField.text!)"])

                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.fullNameTextField.text = ""
                    self.userIDTextField.text = ""

                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MatchingVC")
                    self.present(vc!, animated: true, completion: nil)

                } else {

                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func handleForgetPassword() {

        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { ( error ) in

            if let error = error {

                print(error.localizedDescription)

            } else {

                print("Sent password reset mail successfully!")

            }

        }

    }

}
