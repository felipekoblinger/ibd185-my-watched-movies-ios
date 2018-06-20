//
//  AuthService.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/25/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import PromiseKit

enum AuthService {
    case auth(username: String, password: String)
    
    static func promiseAuth(username: String, password: String) -> Promise<JSON> {
        let provider = MoyaProvider<AuthService>()
        return Promise {
            promise in
            provider.request(.auth(username: username, password: password)) { result in
                switch result {
                case let .success(response):
                    let json = JSON(response.data)
                    promise.fulfill(json)
                case let .failure(error):
                    promise.reject(error)
                }
            }
        }
    }
        
}

extension AuthService: TargetType {
    var baseURL: URL {
        return URL(string: ServerConstants.BaseURL)!
    }
    
    var path: String {
        switch self {
        case .auth:
            return "/auth/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .auth:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case.auth:
            return "[{\"token\": \"anytoken\"}]".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .auth(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
