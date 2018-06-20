//
//  SignUpViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/31/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit

import SwiftValidator
import Moya

import SkyFloatingLabelTextField
import TransitionButton
import CFNotify

import KeychainAccess
import SwiftyJSON
import PromiseKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdayTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var submitButton: TransitionButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let validator = Validator()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Keyboard */
        self.hideKeyboardWhenTappedAround()
        self.setupViewResizerOnKeyboardShown()
        
        /* Validations */
        self.setupValidations()
        
        /* Build DatePicker for BirthdayTextField */
        self.buildDatePicker()
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
        self.validator.registerField(self.usernameTextField,
                                     rules: [RequiredRule(),
                                             MinLengthRule(length: 3),
                                             MaxLengthRule(length: 50)])

        self.validator.registerField(self.passwordTextField,
                                     rules: [RequiredRule(),
                                             MinLengthRule(length: 8),
                                             MaxLengthRule(length: 100),
                                             ConfirmationRule(confirmField: self.confirmPasswordTextField)])

        self.validator.registerField(self.confirmPasswordTextField,
                                     rules: [RequiredRule()])
        
        self.validator.registerField(self.emailTextField,
                                     rules: [RequiredRule(),
                                             EmailRule()])
        
        self.validator.registerField(self.nameTextField,
                                     rules: [RequiredRule(),
                                             MinLengthRule(length: 3),
                                             MaxLengthRule(length: 100)])

        self.validator.registerField(self.birthdayTextField,
                                     rules: [RequiredRule(), DateRule()])
    }
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 15, right: 0)
        self.scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func buildDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil,
                                         action: #selector(datePickerDonePressed))
        toolbar.setItems([doneButton], animated: false)
        
        self.birthdayTextField.inputAccessoryView = toolbar
        self.birthdayTextField.inputView = self.datePicker
        
        datePicker.datePickerMode = .date
    }
    
    @objc func datePickerDonePressed() {
        self.birthdayTextField.text = DateConstants.dateFormatter.string(from: self.datePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func submitAction(_ button: TransitionButton) {
        self.submitButton.startAnimation()
        self.validator.validate(self)
    }
}

extension SignUpViewController: ValidationDelegate {
    func validationSuccessful() {       
        let username = self.usernameTextField.text
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        let name = self.nameTextField.text
        
        let gender = self.genderSegmentedControl.titleForSegment(at: self.genderSegmentedControl.selectedSegmentIndex)!.uppercased()
        let birthday = self.birthdayTextField.text
        
        var classicViewConfig = CFNotify.Config()
        classicViewConfig.initPosition = .top(.random)
        classicViewConfig.appearPosition = .top
        
        
        AccountService.promiseExistsUsernameOrEmail(username: username!, email: email!).then {
            exists -> Promise<Moya.Response> in
            
            var anyDuplicated = false
        
            if exists["username"].boolValue {
                self.usernameTextField.errorMessage = "Username already exists"
                anyDuplicated = true
            } else {
                self.usernameTextField.errorMessage = nil
            }
        
            if exists["email"].boolValue {
                self.emailTextField.errorMessage = "E-mail already exists"
                anyDuplicated = true
            } else {
                self.emailTextField.errorMessage = nil
            }
        
            if anyDuplicated {
                throw DuplicatedError.duplicated
            }
        
            return AccountService.promiseCreate(username: username!, email: email!, password: password!, name: name!, gender: gender, birthday: birthday!)
        }.then { response -> Promise<JSON> in
            let statusCode = response.statusCode
            
            if statusCode != 201 {
                throw DuplicatedError.duplicated
            }
            
            return AuthService.promiseAuth(username: username!, password: password!)
        }.done { response in
            let keychain = Keychain(service: KeychainConstants.MainService)
            keychain["token"] = response["token"].stringValue
            self.submitButton.stopAnimation(animationStyle: .expand, completion: {
                self.performSegue(withIdentifier: "SignUpToMainTabBarSegue", sender: self)
            })
        }.catch { error in
            var errorViewConfig = CFNotify.Config()
            errorViewConfig.initPosition = .bottom(.random)
            errorViewConfig.appearPosition = .bottom
            
            let errorView = CFNotifyView.classicWith(title: "Error",
                                                       body: error.localizedDescription,
                                                       theme: .fail(.dark))
            CFNotify.present(config: errorViewConfig, view: errorView)
            self.submitButton.stopAnimation()
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        self.submitButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.4)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

