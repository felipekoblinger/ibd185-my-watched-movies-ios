//
//  MovieStatisticsEntity.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/13/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import CoreStore
import SwiftyJSON

class MovieStatisticsEntity: CoreStoreObject {
    let total = Value.Required<Int>("total", initial: 0)
    let monthly = Transformable.Required<NSArray>("monthly", initial: [])
    let type = Transformable.Required<NSDictionary>("type", initial: [:])
    let enabled = Value.Required<Bool>("enabled", initial: false)
}
