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
    
    let overview = Value.Optional<String>("overview", initial: "")
    let genres = Value.Optional<String>("genres", initial: "")
    let releaseDate = Value.Optional<Date>("releaseDate", initial: nil)
    
    let createdAt = Value.Required<Date>("createdAt", initial: Date())
    let updatedAt = Value.Required<Date>("updatedAt", initial: Date())
    let section = Transformable.Required<NSString>("section", initial: "", isTransient: true, customGetter: MovieEntity.getSection(_:))

    private static func getSection(_ partialObject: PartialObject<MovieEntity>) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        return dateFormatter.string(from: partialObject.completeObject().date.value) as NSString
    }
    
    func showGenres() -> String {
        let genres = self.genres.value?.split(separator: ",").map{ Genre.init(rawValue: Int($0)!)!.description() }.joined(separator: ", ")
        if (genres?.isEmpty)! {
            return "Not available"
        }
        return genres!
    }
    
    func showYearFromReleaseDate() -> String {
        if self.releaseDate.value == nil {
            return ""
        }
        return String(Calendar.current.component(.year, from: self.releaseDate.value!))
    }
    
    func showReleaseDate() -> String {
        let releaseDate = self.releaseDate.value
        if releaseDate == nil {
            return "Not available"
        }
        return DateConstants.dateFormatter.string(from: releaseDate!)
    }
    
    func showCreatedAt() -> String {
        let createdAt = self.createdAt.value
        return DateConstants.dateTimeFormatter.string(from: createdAt)
    }
    
    func showUpdatedAt() -> String {
        let updatedAt = self.updatedAt.value
        return DateConstants.dateTimeFormatter.string(from: updatedAt)
    }
    
}

extension MovieEntity: ImportableObject {
    typealias ImportSource = [String: Any]
    
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) {
        self.uuid.value = source["uuid"] as! String
        self.title.value = source["title"] as! String
        self.genres.value = source["genres"] as? String
        self.posterPath.value = source["posterPath"] as! String
        self.overview.value = source["overview"] as? String
        
        if !(source["releaseDate"] is NSNull) {
            self.releaseDate.value = DateConstants.dateFormatter.date(from: source["releaseDate"] as! String)!
        }

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
        self.genres.value = source["genres"] as? String
        self.posterPath.value = source["posterPath"] as! String
        self.overview.value = source["overview"] as? String
        
        if !(source["releaseDate"] is NSNull) {
            self.releaseDate.value = DateConstants.dateFormatter.date(from: source["releaseDate"] as! String)!
        }
        
        self.rating.value = source["rating"] as! Int
        self.type.value = source["type"] as! String
        self.theMovieDatabaseId.value = source["theMovieDatabaseId"] as! String
        self.date.value = DateConstants.dateFormatter.date(from: source["date"] as! String)!
        self.createdAt.value = DateConstants.dateTimeFormatter.date(from: source["createdAt"] as! String)!
        self.updatedAt.value = DateConstants.dateTimeFormatter.date(from: source["updatedAt"] as! String)!
    }
    
    
}
