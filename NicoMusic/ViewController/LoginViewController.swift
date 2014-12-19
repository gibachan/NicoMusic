//
//  LoginViewController.swift
//  NicoMusic
//
//  Created by gibachan on 2014/11/07.
//  Copyright (c) 2014 gibachan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: IBOutlet
    // --------------------------------------------------
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: IBAction
    // --------------------------------------------------
    @IBAction func onLogin(sender: UIButton) {
        // hide keyboard
        self.view.endEditing(true)
        
        var email = emailTextField.text
        var password = passwordTextField.text

        email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        emailTextField.text = email
        passwordTextField.text = password
        
        // logout if it has already been logged in
        let login = NicoNicoLogin.getInstance()
        if login.isLoggedIn() {
            login.logout(nil)
        }
        
        if countElements(email) == 0 {
            alertOK("ログイン", message: "ログインメールアドレス/電話番号を入力して下さい。", callback: nil)
            return
        }
        if countElements(password) == 0 {
            alertOK("ログイン", message: "パスワードを入力して下さい。", callback: nil)
            return
        }
        
        login.login(email, password: password, success: {() -> Void in
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(email, forKey: "email")
            defaults.setObject(password, forKey: "password")
            
            self.alertOK("ログイン", message: "ログインしました。") {
                if let nav = self.navigationController {
                    nav.popViewControllerAnimated(true)
                }
            }
            }, failure: {(err) -> Void in
                self.alertOK("ログイン", message: "ログインできませんでした。", callback: nil)
        })
    }
    
    @IBAction func onLogout(sender: UIButton) {
        let login = NicoNicoLogin.getInstance()
        login.logout({() -> Void in
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.removeObjectForKey("email")
            defaults.removeObjectForKey("password")
            
            // UI
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        })
    }
    
    // MARK: UIViewController
    // --------------------------------------------------
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get login data
        let defaults = NSUserDefaults.standardUserDefaults()
        let email = defaults.stringForKey("email")
        let password = defaults.stringForKey("password")
        
        emailTextField.text = email
        passwordTextField.text = password
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
