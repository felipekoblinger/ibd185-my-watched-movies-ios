//
//  SignUpViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/31/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftValidator

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthdayTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let validator = Validator()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.setupViewResizerOnKeyboardShown()
        
        
        /* Build DatePicker for BirthdayTextField */
        self.buildDatePicker()
        
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
                                             MaxLengthRule(length: 50)
                                             ])
        self.validator.registerField(self.passwordTextField,
                                     rules: [
                                        RequiredRule(),
                                        ConfirmationRule(confirmField: self.confirmPasswordTextField)
                                    ])
        self.validator.registerField(self.confirmPasswordTextField, rules: [RequiredRule()])
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
    
    
    @IBAction func submitAction(_ sender: Any) {
        self.validator.validate(self)
    }
    
    @objc func datePickerDonePressed() {
        self.birthdayTextField.text = DateConstants.dateFormatter.string(from: self.datePicker.date)
        self.view.endEditing(true)
    }
}

extension SignUpViewController: ValidationDelegate {
    func validationSuccessful() {
        print("Success")
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        print("Failed")
    }
    
    
}

