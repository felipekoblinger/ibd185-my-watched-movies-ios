//
//  TheMovieDatabaseMovie.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/23/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct TheMovieDatabase {
    let id: Int?
    let title: String?
    let posterPath: String?
    let releaseDate: String?
    let overview: String?
    
    init(id: Int? = nil,
         title: String? = nil,
         posterPath: String? = nil,
         releaseDate: String? = nil,
         overview: String? = nil) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.overview = overview
    }
}

extension TheMovieDatabase: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<TheMovieDatabase> {
        return curry(TheMovieDatabase.init)
            <^> json <|? "id"
            <*> json <|? "title"
            <*> json <|? "poster_path" // Use ? for parsing optional values
            <*> json <|? "release_date" // Custom types that also conform to Decodable just work
            <*> json <|? "overview"
    }
}
