//
//  Challenge.swift
//  
//
//  Created by Madushani Lekam Wasam Liyanage on 3/9/17.
//
//

import Foundation

struct Challenge {
    let id: String
    let name: String
    var champion: String
    var lastUpdated: String
    let type: String

    var lat: Double?
    var long: Double?
    var timeToBeat: Double?
    var distance: Double?
    var path: [Location]?
    
    init(id: String = UUID().uuidString,
         name: String,
         champion: String,
         lastUpdated: String,
         type: String) {
        self.id = id
        self.name = name
        self.champion = champion
        self.lastUpdated = lastUpdated
        self.type = type
    }

    init(id: String = UUID().uuidString,
         name: String,
         champion: String,
         lastUpdated: String,
         type: String,
         lat: Double?,
         long: Double?,
         timeToBeat: Double?,
         distance: Double?,
         path: [Location]?) {
        self.id = id
        self.name = name
        self.champion = champion
        self.lastUpdated = lastUpdated
        self.type = type
        
        self.lat = lat
        self.long = long
        self.timeToBeat = timeToBeat
        self.distance = distance
        self.path = path
    }
    
    
    func toJson()->[String:Any]{
        
        var pathArray: [[String:Double]] = []
        var result: [String: Any] = [
            "name": name,
            "type": type,
            "champion": champion,
            "lastUpdated": lastUpdated
        ]
        
        if let lat = self.lat {
            result["lat"] = lat
        }
        if let long = self.long {
            result["long"] = long
        }
        if let timeToBeat = self.timeToBeat {
            result["timeToBeat"] = timeToBeat
        }
        if let distance = self.distance {
            result["distance"] = distance
        }
        if let path = self.path {
            for location in path {
                let lat = location.latitude
                let long = location.longitude
                
                let dict = ["lat": lat, "long": long]
                pathArray.append(dict)
            }
        }
        
        if pathArray.count > 0 {
            result["path"] = pathArray
        }
        
        return result
    }
}
