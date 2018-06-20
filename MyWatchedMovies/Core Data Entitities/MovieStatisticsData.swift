//
//  MovieStatisticsData.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/14/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import CoreStore

struct MovieStatisticsData {
    static let stack: DataStack = {
        return DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<MovieStatisticsEntity>("MovieStatistics"),
                ],
                versionLock: [
                    "MovieStatistics": [0xd05efc4118e11ea3, 0xbb488fb9af0aa1cd, 0xa751638444079479, 0xbdb57af9b6fb9b04]
                ]
            )
        )
    }()
    
    static func addStorageAndWait() {
        try! MovieStatisticsData.stack.addStorageAndWait(
            SQLiteStore(
                fileName: "MovieStatistics.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
    }
}
