//
//  AuthPlugin.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/25/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Moya

struct AuthPlugin: PluginType {
    let token: String
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}
