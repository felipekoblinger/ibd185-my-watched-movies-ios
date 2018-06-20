//
//  NotSameRule.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/8/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import SwiftValidator

class NotEqualRule: Rule {
    private let notEqualField: ValidatableField
    private var message : String
    
    /**
     Initializes a `ConfirmationRule` object to validate the text of a field that should equal the text of another field.
     
     - parameter confirmField: field to which original field will be compared to.
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(notEqualField: ValidatableField, message : String = "This field must not be equal"){
        self.notEqualField = notEqualField
        self.message = message
    }
    
    /**
     Used to validate a field.
     
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        return notEqualField.validationText != value
    }
    
    /**
     Displays an error message when text field fails validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}