//
//  DateConstants.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/29/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation

class DateConstants {
    static var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter
        }
    }
    
    static var dateTimeFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            return dateFormatter
        }
    }
}
