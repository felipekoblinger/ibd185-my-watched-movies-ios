//
//  MovieType.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/7/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
enum MovieType {
    case SUBTITLED
    case DUBBED
    case ORIGINAL
    case UNKNOWN
    
    init?(rawValue: String) {
        switch rawValue {
        case "SUBTITLED": self = .SUBTITLED
        case "DUBBED": self = .DUBBED
        case "ORIGINAL": self = .ORIGINAL
        
        default:
            self = .UNKNOWN
        }
    }
    
}
