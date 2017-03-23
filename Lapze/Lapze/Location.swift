//
//  Location.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import CoreLocation

struct Location{
    let latitude: Double
    let longitude: Double
    
    init(lat: Double, long: Double){
        self.latitude = lat
        self.longitude = long
    }
    
    init(location: CLLocationCoordinate2D){
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    init(location: CLLocation){
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    
    func toJson()-> [String:Double]{
        return ["lat":self.latitude,"long":self.longitude]
    }
    
}
