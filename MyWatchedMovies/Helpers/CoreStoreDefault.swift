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
    
    @discardableResult
    init() {
        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<MovieEntity>("MovieEntity")
                ],
                versionLock: [
                    "MovieEntity": [0x24766583464b2b28, 0x6e34a821ed722831, 0x3a5cad82e3761bc3, 0x37719fd4404b0a59]
                ]
            )
        )
        
        _ = dataStack.addStorage(
            SQLiteStore(
                fileName: "MyWatchedMovies.sqlite"
            ),
            completion: { (result) -> Void in
                switch result {
                case .success:
                    print("Successfully added sqlite store.")
                case .failure(let error):
                    print("Failed adding sqlite store with error: \(error)")
                }
            }
        )
        CoreStore.defaultStack = dataStack
    }

}
