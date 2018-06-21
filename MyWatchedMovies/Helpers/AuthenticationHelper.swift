//
//  AuthenticationHelper.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/30/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation

import KeychainAccess
import JWTDecode
import Moya
import SwiftyJSON

class AuthenticationHelper {
    
    private static let keychain = Keychain(service: KeychainConstants.MainService)
    
    static func isLogged() -> Bool {
        
        let token = self.keychain["token"]
        
        if token == nil {
            return false
        }
        
        guard !(token?.isEmpty)! else {
            return false
        }
        
        let jwt = try! decode(jwt: token!)
        return !jwt.expired
    }
    
    static func refreshToken() {
        if self.isLogged() {
            let provider = MoyaProvider<AuthService>(
                plugins: [
                    AuthPlugin(token: self.keychain["token"]! )
                ]
            )
            provider.request(.refresh()) { result in
                switch result {
                case let .success(response):
                    print(response.statusCode)
                    if response.statusCode == 200 {
                        let json = JSON(response.data)
                        self.setToken(token: json["token"].stringValue)
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    static func shouldLogout() -> Bool {
        if !self.isLogged() && keychain["token"] != nil {
            return true
        }
        return false
    }
    
    static func logout() {
        keychain["token"] = nil
    }
    
    private static func setToken(token: String) {
        self.keychain["token"] = token
    }
}
