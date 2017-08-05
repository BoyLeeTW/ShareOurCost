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

    var accountManager = AccountManager()

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

        if emailTextField.text == "" || passwordTextField.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Please enter all information", preferredStyle: .alert)

            //what is handler
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            present(alertController, animated: true, completion: nil)

        } else {

            accountManager.firebaseSignIn(email: emailTextField.text!, password: passwordTextField.text!)

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MatchingVC")

            self.present(vc!, animated: true, completion: nil)

        }
    }

    func handleRegistration() {

        if emailTextField.text == "" || passwordTextField.text == "" || fullNameTextField.text == "" || userIDTextField.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Please enter all information", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion:  nil)

        } else {

            let result = accountManager.checkIfUserIDUnique(userID: userIDTextField.text!)

            if result == true {
            
            accountManager.firebaseRigistration(email: emailTextField.text!, password: passwordTextField.text!, userName: fullNameTextField.text!, userID: userIDTextField.text!)

            self.emailTextField.text = ""

            self.passwordTextField.text = ""

            self.fullNameTextField.text = ""

            self.userIDTextField.text = ""

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MatchingVC")

            self.present(vc!, animated: true, completion: nil)

            } else {

                let alertController = UIAlertController(title: "Error", message: "UserID is already used!", preferredStyle: .alert)

                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                alertController.addAction(defaultAction)

                self.present(alertController, animated: true, completion:  nil)

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
