//
//  Path.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/8/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class Path {
    
    private let path = GMSMutablePath()
    private var polyline = GMSPolyline()
    
    func getPolyline(_ coordinatesArr: [Location] ) -> GMSPolyline {
         path.removeAllCoordinates()
        for location in coordinatesArr {
            let lat = location.latitude
            let long = location.longitude
            let coordinates = CLLocationCoordinate2D(latitude: lat , longitude: long)
            path.add(coordinates)
        }
        polyline.path = path
        return polyline
    }
    
    func removePolyline() {
        polyline.map = nil
    }
    
    func toJson(array: [Location])->[[String:Double]]{
        var resultsArray: [[String:Double]] = []
        for location in array{
            let dict = ["lat": location.latitude, "long": location.longitude]
            resultsArray.append(dict)
        }
        return resultsArray
    }
}
