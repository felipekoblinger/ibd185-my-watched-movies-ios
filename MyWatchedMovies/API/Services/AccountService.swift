//
//  AccountService.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/2/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya
import PromiseKit
import SwiftyJSON
import KeychainAccess

enum AccountService {
    case create(username: String,
                email: String,
                password: String,
                name: String,
                gender: String,
                birthday: String)
    case existsUsernameOrEmail(username: String, email: String)
    case me()
    case changePassword(currentPassword: String, newPassword: String)
    
    static func promiseExistsUsernameOrEmail(username: String, email: String) -> Promise<JSON> {
        let provider = MoyaProvider<AccountService>()
        return Promise {
            promise in
            provider.request(.existsUsernameOrEmail(username: username, email: email)) { result in
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
    
    static func promiseCreate(username: String,
                              email: String,
                              password: String,
                              name: String,
                              gender: String,
                              birthday: String) -> Promise<Moya.Response> {
        let provider = MoyaProvider<AccountService>()
        return Promise {
            promise in
                provider.request(.create(username: username,
                                         email: email,
                                         password: password,
                                         name: name,
                                         gender: gender,
                                         birthday: birthday)) { result in
                                            switch result {
                                            case let .success(response):
                                                promise.fulfill(response)
                                            case let .failure(error):
                                                promise.reject(error)
                                            }
            }
        }
        
    }
    
    static func promiseChangePassword(currentPassword: String,
                                      newPassword: String) -> Promise<Moya.Response> {
        let provider = MoyaProvider<AccountService>(
            plugins: [
                AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
            ]
        )
        
        return Promise {
            promise in
            provider.request(.changePassword(currentPassword: currentPassword,
                                             newPassword: newPassword)) { result in
                                                switch result {
                                                case let .success(response):
                                                    promise.fulfill(response)
                                                case let .failure(error):
                                                    promise.reject(error)
                                                }
            }
        }
    }
    

    
}

extension AccountService: TargetType {
    var baseURL: URL {
        return URL(string: ServerConstants.BaseURL)!
    }
    
    var path: String {
        switch self {
        case .create: return "/accounts/"
        case .existsUsernameOrEmail: return "/accounts/exists-username-or-email/"
        case .me: return "/accounts/me/"
        case .changePassword: return "/accounts/change-password/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create: return .post
        case .existsUsernameOrEmail, .me: return .get
        case .changePassword: return .put
        }
    }
    
    var sampleData: Data {
        switch self {
        case .create:
            return "".data(using: String.Encoding.utf8)!
        case .existsUsernameOrEmail:
            return "".data(using: String.Encoding.utf8)!
        case .me:
            return "".data(using: String.Encoding.utf8)!
        case .changePassword:
            return "".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .create(let username, let email, let password, let name, let gender, let birthday):
            let parameters = [
                "username": username,
                "email": email,
                "password": password,
                "name": name,
                "gender": gender,
                "birthday": birthday
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .existsUsernameOrEmail(let username, let email):
            let parameters = [
                "username": username,
                "email": email
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .me:
            return .requestPlain
        case .changePassword(let currentPassword, let newPassword):
            let parameters = [
                "currentPassword": currentPassword,
                "newPassword": newPassword
            ]
            return.requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
