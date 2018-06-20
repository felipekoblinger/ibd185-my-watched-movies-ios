//
//  MovieService.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/26/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya

enum MovieService {
    case addMovie(date: Date, rating: Int, type: String, theMovieDatabase: TheMovieDatabase)
    case movies()
    case deleteMovie(uuid: String)
    case updateMovie(uuid: String, date: Date, rating: Int, type: String)
}

extension MovieService: TargetType {
    var baseURL: URL {
        return URL(string: ServerConstants.BaseURL)!
    }
    
    var path: String {
        switch self {
        case .addMovie, .movies:
            return "/movies/"
        case .deleteMovie(let uuid), .updateMovie(let uuid, _, _, _):
            return "/movies/\(uuid)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addMovie: return .post
        case .movies: return .get
        case .deleteMovie: return .delete
        case .updateMovie: return .put
        }

    }
    
    var sampleData: Data {
        switch self {
        case .addMovie:
            return "[{\"title\": \"anytitle\"}]".data(using: String.Encoding.utf8)!
        case .movies:
            return "[{\"title\": \"anytitle\"}]".data(using: String.Encoding.utf8)!
        case .deleteMovie:
            return "".data(using: String.Encoding.utf8)!
        case .updateMovie:
            return "[{\"title\": \"anytitle\"}]".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .addMovie(let date, let rating, let type, let theMovieDatabase):
            let title = theMovieDatabase.title!
            let theMovieDatabaseId = theMovieDatabase.id!
            
            let posterPath = theMovieDatabase.posterPath ?? "unknown"
            let overview = theMovieDatabase.overview ?? "unknown"
            var genres = ""
            
            if !(theMovieDatabase.genres?.isEmpty)! {
                let stringArray = theMovieDatabase.genres?.map{ id in String(id) }
                genres = (stringArray?.joined(separator: ","))!
            }
            
            let dateFormatted = DateConstants.dateFormatter.string(from: date)
            let typeUppercased = type.uppercased()
            
            var releaseDateShow = ""
            if !(theMovieDatabase.releaseDate?.isEmpty)! {
                let releaseDateFormat = DateFormatter()
                releaseDateFormat.dateFormat = "yyyy-MM-dd"
                let releaseDate = releaseDateFormat.date(from: theMovieDatabase.releaseDate!)
                releaseDateShow = DateConstants.dateFormatter.string(from: releaseDate!)
            }

            return .requestParameters(parameters:
                ["date": dateFormatted,
                 "rating": rating,
                 "title": title,
                 "posterPath": posterPath,
                 "theMovieDatabaseId": theMovieDatabaseId,
                 "type": typeUppercased,
                 "overview": overview,
                 "genres": genres,
                 "releaseDate": releaseDateShow
                ], encoding: JSONEncoding.default)
        case .movies:
            return .requestPlain
        case .deleteMovie:
            return .requestPlain
            
        case .updateMovie(_, let date, let rating, let type):
            let dateFormatted = DateConstants.dateFormatter.string(from: date)
            let typeUppercased = type.uppercased()
            
            return .requestParameters(parameters: ["date": dateFormatted, "type": typeUppercased, "rating": rating],
                                      encoding: JSONEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        return nil
    }
}
