//
//  ViewController.swift
//  On The Map
//
//  Created by Christopher Weaver on 8/3/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextField: UITextView!
    
    @IBAction func signUp(_ sender: UITextField) {
        let webDetailController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webDetailController.urlRequest = "https://www.udacity.com/account/auth#!/signup"
        self.present(webDetailController, animated: true, completion: nil)
    }

    @IBAction func loginButton(_ sender: AnyObject) {
        self.view.endEditing(true)
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextField.text = "Please enter a username and password"
        } else {
            debugTextField.text = "Logging in..."
            Udacity.sharedInstance().loginPostSession(usernameTextField.text!, password: passwordTextField.text!) { (success, error) in performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        if error == "Your Udacity post request returned a status code other than 2xx!" {
                            self.displayAlert("incorrect username/password credentials")
                        } else if  error == "The Internet connection appears to be offline." {
                            self.displayAlert("There is a problem with your internet connection")
                        }
                        else {
                            self.displayAlert("an unknown error occured")
                        }
                    }
                }
            }
        }
    }
    
    func completeLogin() {
        Parse.sharedInstance().getStudentLocations() { (success, error) in
            if success { Udacity.sharedInstance().logoutDeleteSession() { (success, error) in
                if success {
                    performUIUpdatesOnMain {
                        var controller: UITabBarController
                        controller = self.storyboard!.instantiateViewController(withIdentifier: "UITabBarController") as! UITabBarController
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func displayAlert(_ text: String) {
        let downloadAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.alert)
        downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            self.debugTextField.text = ""
        }))
        self.present(downloadAlert, animated: true, completion: nil)
    }

    
   override var shouldAutorotate : Bool{
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
}

