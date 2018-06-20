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
    let genres: [Int]?
    
    init(id: Int? = nil,
         title: String? = nil,
         posterPath: String? = nil,
         releaseDate: String? = nil,
         overview: String? = nil,
         genres: [Int]? = nil) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.overview = overview
        self.genres = genres
    }
    
    func showGenre() -> String {
        let genres = self.genres!.map{ Genre.init(rawValue: $0)!.description() }.joined(separator: ", ")
        
        if genres.isEmpty {
            return "Not available"
        }
        return genres
    }
    
    func showReleaseDate() -> String {
        if self.releaseDate == nil || (self.releaseDate?.isEmpty)! {
            return "??-??-????"
        }
        
        let date = DateConstants.dateFormatterUS.date(from: self.releaseDate!)
        return DateConstants.dateFormatter.string(from: date!)
    }
    
    func showOverview() -> String {
        if self.overview == nil || (self.overview?.isEmpty)! {
            return "Not available."
        }
        return self.overview!
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
            <*> (json <|| "genre_ids")
    }
}
