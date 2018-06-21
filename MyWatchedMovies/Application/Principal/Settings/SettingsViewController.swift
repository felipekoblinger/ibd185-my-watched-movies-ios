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
                    AuthenticationHelper.logout()
                
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let authNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "AuthNavigationController") as! UINavigationController
                    self.present(authNavigationController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
