//
//  SettingsViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import KeychainAccess

class SettingsViewController: UITableViewController {
    @IBAction func unwindToSettingsViewController(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        print("Loaded: Settings View Controller")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            
            let alert = UIAlertController(title: "Logout",
                                          message: "Would you like to logout?",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive, handler: {
                action in
                    let keychain = Keychain(service: KeychainConstants.MainService)
                    keychain["token"] = nil
                
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let authViewController = mainStoryboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
                    self.present(authViewController, animated: true, completion: nil)
//                    self.window?.rootViewController = mainUITabBarController
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
