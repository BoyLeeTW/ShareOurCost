//
//  ViewController.swift
//  ShareOurCost
//
//  Created by Brad on 25/07/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import NVActivityIndicatorView

class ViewController: UIViewController {

    @IBOutlet weak var signInOrRegisterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signInOrUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var userIDTextField: UITextField!

    var accountManager = AccountManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpButtons()

        fullNameTextField.isHidden = true

        userIDTextField.isHidden = true

        signInOrRegisterSegmentedControl.addTarget(self, action: #selector(handleSignInOrRegisterChange), for: UIControlEvents.valueChanged)

    }

    func setUpButtons() {

        self.emailTextField.layer.borderWidth = 3
        self.emailTextField.layer.borderColor = UIColor.white.cgColor
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.passwordTextField.layer.borderWidth = 3
        self.passwordTextField.layer.borderColor = UIColor.white.cgColor
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.fullNameTextField.layer.borderWidth = 3
        self.fullNameTextField.layer.borderColor = UIColor.white.cgColor
        self.fullNameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        self.userIDTextField.layer.borderWidth = 3
        self.userIDTextField.layer.borderColor = UIColor.white.cgColor
        self.userIDTextField.attributedPlaceholder = NSAttributedString(string: "User ID", attributes: [NSForegroundColorAttributeName: UIColor(red: 172/255, green: 206/255, blue: 211/255, alpha: 1.0)])

        signInOrUpButton.addTarget(self, action: #selector(handleSignInOrRegister), for: .touchUpInside)
        
        forgetPasswordButton.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)

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

            let alertController = UIAlertController(title: "Error",
                                                    message: "Please enter all information",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",
                                              style: .cancel,
                                              handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)

        } else {

            let activityData = ActivityData(message: "Loading...")

            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)

            accountManager.firebaseSignIn(email: emailTextField.text!,
                                          password: passwordTextField.text!,
                                          completion: { (loginResultBool, error) in

                if loginResultBool == true {

                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")

                    self.present(vc!, animated: true, completion: nil)

                }

                else {

                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)

                }

            })

        }

    }

    func handleRegistration() {

        guard let emailText = emailTextField.text,
              let passwordText = passwordTextField.text,
              let nameText = fullNameTextField.text,
              let userIDText = userIDTextField.text
        else {

            let alertController = UIAlertController(title: "Error",
                                                    message: "Please enter all information",
                                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",
                                              style: .cancel,
                                              handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion:  nil)

            return
        }

        //weak to avoid memory leak
        accountManager.checkIfUserIDUnique(userID: userIDText, completion: { [weak self] (resultBool) in
            //in order to use self instead of self?
            guard let `self` = self else { return }

            if resultBool == true {

                if self.emailTextField.text == "" || self.passwordTextField.text == "" || self.fullNameTextField.text == "" || self.userIDTextField.text == "" {

                    let alertController = UIAlertController(title: "Oops",
                                                            message: "Please fill in all information",
                                                            preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion:  nil)

                    return

                }

                let activityData = ActivityData(message: "Loading...")

                NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)

                self.accountManager.firebaseRegistration(email: emailText,
                                                         password: passwordText,
                                                         userName: nameText,
                                                         userID: userIDText,
                                                         completion: {

                                                            

                                                            self.emailTextField.text = ""
                                                            self.passwordTextField.text = ""
                                                            self.fullNameTextField.text = ""
                                                            self.userIDTextField.text = ""

                                                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                                                            self.present(vc!, animated: true, completion: nil)

                })

            } else {

                let alertController = UIAlertController(title: "Oops",
                                                        message: "UserID is already used!",
                                                        preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion:  nil)

            }
        })
    }

    func handleForgetPassword() {

        if emailTextField.text != "" {

            accountManager.firebaseResetPassword(email: emailTextField.text!)

            let alertController = UIAlertController(title: "Success",
                                                    message: "Please check your email to reset password",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion:  nil)

        } else {

            let alertController = UIAlertController(title: "Oops",
                                                    message: "Please fill in your email",
                                                    preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion:  nil)

        }

    }

}
