//
//  CoreStoreDefault.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/29/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import CoreStore

class CoreStoreDefault {
    
    init() {
        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<MovieEntity>("MovieEntity")
                ],
                versionLock: [
                    "MovieEntity": [0x185d9a75321e3c58, 0x1707bc163c07fa6f, 0x381cfb16869885f, 0x89d4fe86c42197a4]
                ]
            )
        )
        CoreStore.defaultStack = dataStack
    }
    
    static func addStorageAndWait() {
        try! CoreStore.addStorageAndWait(
            SQLiteStore(
                fileName: "Movies.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
    }

}
