//
//  ChangePasswordViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/8/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import TransitionButton
import StatusAlert
import CFNotify

import SwiftValidator
import PromiseKit

class ChangePasswordViewController: UIViewController {


    @IBOutlet weak var submitButton: TransitionButton!
    
    @IBOutlet weak var currentPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var newPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmNewPasswordTextField: SkyFloatingLabelTextField!
    
    /* Validation */
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        self.currentPasswordTextField.text = nil
        self.newPasswordTextField.text = nil
        self.confirmNewPasswordTextField.text = nil
        self.setupValidations()
    }
    
    func setupValidations() {
        self.validator.styleTransformers(success: { (validationRule) in
            let textField = validationRule.field as? SkyFloatingLabelTextField
            textField?.errorMessage = nil
        }, error: { (validationError) in
            let textField = validationError.field as? SkyFloatingLabelTextField
            textField?.errorMessage = validationError.errorMessage
        })
        
        /* Validations */
        self.validator.registerField(self.currentPasswordTextField, rules: [RequiredRule()])
        
        self.validator.registerField(self.newPasswordTextField,
                                     rules: [RequiredRule(),
                                             MinLengthRule(length: 8),
                                             MaxLengthRule(length: 100),
                                             ConfirmationRule(confirmField: self.confirmNewPasswordTextField),
                                             NotEqualRule(notEqualField: self.currentPasswordTextField, message: "Can't be the same as current password")
                                             ])
        
        self.validator.registerField(self.confirmNewPasswordTextField,
                                     rules: [RequiredRule()])
    }
    
    
    @IBAction func submitAction(_ button: TransitionButton) {
        self.validator.validate(self)
        self.submitButton.startAnimation()
    }
    
}

extension ChangePasswordViewController: ValidationDelegate {
    func validationSuccessful() {
        let currentPassword = self.currentPasswordTextField.text
        let newPassword = self.newPasswordTextField.text
        
        var viewConfig = CFNotify.Config()
        viewConfig.initPosition = .bottom(.random)
        viewConfig.appearPosition = .bottom
        
        AccountService.promiseChangePassword(currentPassword: currentPassword!, newPassword: newPassword!).done { response in
            
            switch response.statusCode {
            case 200:
                self.submitButton.stopAnimation()
                self.performSegue(withIdentifier: "unwindToSettingsViewController", sender: self)
                // ADD: message ok
                let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "Change Password - Success"),
                                                          title: "Password changed!",
                                                          message: "Your pasword was changed successfully!")
                statusAlert.showInKeyWindow()
            case 403:
                self.submitButton.stopAnimation(animationStyle: .shake)
                let wrongCurrentPasswordView = CFNotifyView.classicWith(title: "Wrong Current Password",
                                                                        body: "Please, check your current password.",
                                                                        theme: .warning(.dark))
                CFNotify.present(config: viewConfig, view: wrongCurrentPasswordView)
            default:
                self.submitButton.stopAnimation()
                let wrongCurrentPasswordView = CFNotifyView.classicWith(title: "Something wrong occured.",
                                                                        body: "Please, contact us with details about your problem.",
                                                                        theme: .fail(.dark))
                CFNotify.present(config: viewConfig, view: wrongCurrentPasswordView)
            }
            
            }.catch { error in
                self.submitButton.stopAnimation()
                let wrongCurrentPasswordView = CFNotifyView.classicWith(title: "Error",
                                                                        body: error.localizedDescription,
                                                                        theme: .warning(.dark))
                CFNotify.present(config: viewConfig, view: wrongCurrentPasswordView)
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        self.submitButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2)
    }
}
