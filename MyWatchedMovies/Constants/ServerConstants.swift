//
//  ServerConstants.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation

struct ServerConstants {
    private struct Domains {
        static let Development = "http://localhost:8080"
        static let Production = "https://my-watched-movies.herokuapp.com"
    }
    
    private  static let Domain = Domains.Production
    
    static let BaseURL = Domain
    
    struct Routes {
        static let AuthRoute = BaseURL + "/auth/"
        static let MoviesRoute = BaseURL + "/movies/"
    }
}
