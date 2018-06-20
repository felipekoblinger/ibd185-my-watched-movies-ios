//
//  MovieService.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/26/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya

enum MovieStatisticsService {
    case overall()
}

extension MovieStatisticsService: TargetType {
    var baseURL: URL {
        return URL(string: ServerConstants.BaseURL)!
    }
    
    var path: String {
        switch self {
        case .overall:
            return "/movies-statistics/overall/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .overall: return .get
        }

    }
    
    var sampleData: Data {
        switch self {
        case .overall:
            return "[]".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .overall:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        return nil
    }
}
