//
//  Utils.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/28/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Argo


func convertDate(dateString: String) -> Decoded<Date> {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    return .fromOptional(dateFormatter.date(from: dateString))
}

func convertDateTime(dateString: String) -> Decoded<Date> {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    return .fromOptional(dateFormatter.date(from: dateString))
}
