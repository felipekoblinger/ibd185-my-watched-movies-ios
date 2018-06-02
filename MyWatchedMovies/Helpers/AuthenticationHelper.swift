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

class AuthenticationHelper {
    
    private static let keychain = Keychain(service: KeychainConstants.MainService)
    
    static func isLogged() -> Bool {
        if let token = self.keychain["token"] {
            let jwt = try! decode(jwt: token)
            return jwt.expired
        }
        return false
    }
}
