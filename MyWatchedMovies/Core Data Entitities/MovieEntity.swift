//
//  MovieCoreStoreObject.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/29/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import CoreStore

class MovieEntity: CoreStoreObject {
    let uuid = Value.Required<String>("uuid", initial: "")
    let title = Value.Required<String>("title", initial: "")
    let posterPath = Value.Required<String>("posterPath", initial: "")
    let rating = Value.Required<Int>("rating", initial: 0)
    let type = Value.Required<String>("type", initial: "")
    let theMovieDatabaseId = Value.Required<String>("theMovieDatabaseId", initial: "")
    let date = Value.Required<Date>("date", initial: Date())
    let createdAt = Value.Required<Date>("createdAt", initial: Date())
    let updatedAt = Value.Required<Date>("updatedAt", initial: Date())
    let section = Transformable.Required<NSString>("section", initial: "", isTransient: true, customGetter: MovieEntity.getSection(_:))

    private static func getSection(_ partialObject: PartialObject<MovieEntity>) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        return dateFormatter.string(from: partialObject.completeObject().date.value) as NSString
    }
}

extension MovieEntity: ImportableObject {
    typealias ImportSource = [String: Any]
    
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) {
        
        self.uuid.value = source["uuid"] as! String
        self.title.value = source["title"] as! String
        self.posterPath.value = source["posterPath"] as! String
        self.rating.value = source["rating"] as! Int
        self.type.value = source["type"] as! String
        self.theMovieDatabaseId.value = source["theMovieDatabaseId"] as! String
        self.date.value = DateConstants.dateFormatter.date(from: source["date"] as! String)!
        self.createdAt.value = DateConstants.dateTimeFormatter.date(from: source["createdAt"] as! String)!
        self.updatedAt.value = DateConstants.dateTimeFormatter.date(from: source["updatedAt"] as! String)!
    }
}

extension MovieEntity: ImportableUniqueObject {
    typealias UniqueIDType = String
    
    public static var uniqueIDKeyPath: String {
        return String(keyPath: \MovieEntity.uuid)
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return source["uuid"] as? String
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        self.uuid.value = source["uuid"] as! String
        self.title.value = source["title"] as! String
        self.posterPath.value = source["posterPath"] as! String
        self.rating.value = source["rating"] as! Int
        self.type.value = source["type"] as! String
        self.theMovieDatabaseId.value = source["theMovieDatabaseId"] as! String
        self.date.value = DateConstants.dateFormatter.date(from: source["date"] as! String)!
        self.createdAt.value = DateConstants.dateTimeFormatter.date(from: source["createdAt"] as! String)!
        self.updatedAt.value = DateConstants.dateTimeFormatter.date(from: source["updatedAt"] as! String)!
    }
    
    
}
