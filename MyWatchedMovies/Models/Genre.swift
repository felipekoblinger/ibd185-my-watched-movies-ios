//
//  Genre.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/6/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation

enum Genre: Int {
    case ACTION = 28
    case ADVENTURE = 12
    case ANIMATION = 16
    case COMEDY = 35
    case CRIME = 80
    case DOCUMENTARY = 99
    case DRAMA = 18
    case FAMILY = 10751
    case FANTASY = 14
    case HISTORY = 36
    case HORROR = 27
    case MUSIC = 10402
    case MYSTERY = 9648
    case ROMANCE = 10749
    case SCIENCE_FICTION = 878
    case TV_MOVIE = 10770
    case THRILLER = 53
    case WAR = 10752
    case WESTERN = 37
    case UNKNOWN = -1
    
    init?(rawValue: Int) {
        switch rawValue {
        case 28: self = .ACTION
        case 12: self = .ADVENTURE
        case 16: self = .ANIMATION
        case 35: self = .COMEDY
        case 80: self = .CRIME
        case 99: self = .DOCUMENTARY
        case 18: self = .DRAMA
        case 10751: self = .FAMILY
        case 14: self = .FANTASY
        case 36: self = .HISTORY
        case 27: self = .HORROR
        case 10402: self = .MUSIC
        case 9648: self = .MYSTERY
        case 10749: self = .ROMANCE
        case 878: self = .SCIENCE_FICTION
        case 10770: self = .TV_MOVIE
        case 53: self = .THRILLER
        case 10752: self = .WAR
        case 37: self = .WESTERN
        default:
            self = .UNKNOWN
        }
    }
    
    func description() -> String {
        switch self {
        case .ACTION: return "Action"
        case .ADVENTURE: return "Adventure"
        case .ANIMATION: return "Animation"
        case .COMEDY: return "Comedy"
        case .CRIME: return "Crime"
        case .DOCUMENTARY: return "Documentary"
        case .DRAMA: return "Drama"
        case .FAMILY: return "Family"
        case .FANTASY: return "Fantasy"
        case .HISTORY: return "History"
        case .HORROR: return "Horror"
        case .MUSIC: return "Music"
        case .MYSTERY: return "Mystery"
        case .ROMANCE: return "Romance"
        case .SCIENCE_FICTION: return "Science Fiction"
        case .TV_MOVIE: return "TV Movie"
        case .THRILLER: return "Thriller"
        case .WAR: return "War"
        case .WESTERN: return "Western"
        default:
            return "Unknown"
        }
    }
}
