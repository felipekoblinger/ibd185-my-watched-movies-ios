//
//  DateRule.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/2/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import SwiftValidator

class DateRule: Rule {
    func errorMessage() -> String {
        return "Not a valid date"
    }
    
    func validate(_ value: String) -> Bool {
        let date = DateConstants.dateFormatter.date(from: value)
        if date == nil { return false }
        
        return date! <= Date()
    }
    
    func validate(_ value: Date) -> Bool {
        return value <= Date()
    }
}
