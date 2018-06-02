//
//  LoginViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit

import Moya
import SwiftyJSON
import KeychainAccess

import TransitionButton
import CFNotify

class AuthViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.performSegue(withIdentifier: "SignUpSegue", sender: self)
    }
    
    
    @IBAction func loginAction(_ button: TransitionButton) {
        button.startAnimation()
        
        
        let username = self.usernameTextField.text!
        let password = self.passwordTextField.text!
        
        let provider = MoyaProvider<AuthService>()
        provider.request(.auth(username: username, password: password)) { result in
            var classicViewConfig = CFNotify.Config()
            classicViewConfig.initPosition = .top(.random)
            classicViewConfig.appearPosition = .top
            
            switch result {
            case let .success(response):
                let statusCode = response.statusCode

                switch statusCode {
                case 200:
                    let data = JSON(response.data)
                    let keychain = Keychain(service: KeychainConstants.MainService)
                    keychain["token"] = data["token"].stringValue
                    
                    button.stopAnimation(animationStyle: .expand, completion: {
                        self.performSegue(withIdentifier: "MainTabBar", sender: self)
                    })
                case 401:
                    let classicView = CFNotifyView.classicWith(title: "Wrong username or password",
                                                                body: "Please, check your credentials.",
                                                                theme: .warning(.dark))
                    button.stopAnimation(animationStyle: .shake, completion: {
                        CFNotify.present(config: classicViewConfig, view: classicView)
                    })
                default:
                    let classicView = CFNotifyView.classicWith(title: "Status code \(statusCode)",
                                                               body: "Please, contact us.",
                                                               theme: .fail(.light))
                    button.stopAnimation(completion: {
                        CFNotify.present(config: classicViewConfig, view: classicView)
                    })
                }
            case let .failure(error):
                let classicView = CFNotifyView.classicWith(title: "Network Error",
                    body: error.errorDescription!,
                    theme: .fail(.dark))
                button.stopAnimation(completion: {
                    CFNotify.present(config: classicViewConfig, view: classicView)
                })
            }
        }
    }
    
}
