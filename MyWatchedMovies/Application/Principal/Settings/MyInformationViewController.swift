//
//  MyInformationViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/8/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit

import Moya
import KeychainAccess
import SwiftyJSON

class MyInformationViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = .white
        
        let provider = MoyaProvider<AccountService>(
            plugins: [
                AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
            ]
        )
        provider.request(.me()) { result in
            switch result {
            case let .success(response):
                let account = JSON(response.data)
                self.usernameLabel.text = account["username"].stringValue
                self.emailLabel.text = account["email"].stringValue
                self.nameLabel.text = account["name"].stringValue
                self.genderLabel.text = account["gender"].stringValue
                self.birthdayLabel.text = account["birthday"].stringValue
            case let .failure(error):
                print(error)
            }
        }
    }
}
