//
//  TheMovieDatabaseService.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/25/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya

enum TheMovieDatabaseService {
    case searchMovies(term: String)
}

extension TheMovieDatabaseService: TargetType {
    var baseURL: URL {
        return URL(string: ServerConstants.BaseURL)!
    }
    
    var path: String {
        switch self {
        case .searchMovies:
            return "/the-movie-database/search/"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .searchMovies:
            return "{  \"page\": 1, \"total_results\": 18, \"total_pages\": 1, \"results\": [] }".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .searchMovies(let term):
            var params: [String: Any] = [:]
            params["term"] = term
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    

}
