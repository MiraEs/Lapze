//
//  LocationStore.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase

protocol LocationObserver {
    var identifier: String { get }
    func locationsDidUpdate(id: String, location: Location, updateType type: UpdateType)
}

class LocationStore: FirebaseNodeObserver {
    static let manager: LocationStore = LocationStore()
    private var observers: [String: LocationObserver] = [:]

    private var userCurrentLocation: [Location] = []

    private init(){}
    
    func createPathArray(_ locationArray: [Location]) -> [[String:Any]] {
        
        var array: [[String:Any]] = []
        
        for location in locationArray {
            let dict = ["lat": location.latitude, "long": location.longitude]
            array.append(dict)
        }
        
        return array
    }
    
    func isUserWithinRadius(userLocation: CLLocation, challengeLocation: Location, radius: Double = 100.0) -> Bool {
        
        let loc = CLLocation(latitude: challengeLocation.latitude, longitude: challengeLocation.longitude)
        let distance = userLocation.distance(from: loc)
        
        if  distance < radius {
            return true
        }
        
        return false
    }
    
    private func createLocation(snapshot: FIRDataSnapshot) -> Location?{
        guard let value = snapshot.value as? [String:Double],
            let lat = value["lat"],
            let long = value["long"] else{ return nil }
        return Location(lat: lat, long: long)
    }
    
    func addToUserCurrentLocation(location: Location){
        self.userCurrentLocation.append(location)
    }
    
    func userPathToJson() -> [[String:Any]]{
        var returnArray: [[String:Any]] = []
        for location in userCurrentLocation{
            returnArray.append(location.toJson())
        }
        return returnArray
    }
    
    func getPath(id: String, closure: @escaping ([Location]) -> Void){
        FirebaseManager.shared.updateFirebase { (ref) in
            var returnArray: [Location] = []
            let childRef = ref.child("Location").child(id)
            
            childRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children{
                    dump(child)
                    guard  let snap = child as? FIRDataSnapshot else { return }
                    
                    if let location = self.createLocation(snapshot: snap){
                        returnArray.append(location)
                        
                    }
                }
                closure(returnArray)
            })
        }
        
    }
    
    func nodeDidUpdate(snapshot: FIRDataSnapshot, updateType type: UpdateType) {
        guard let location = createLocation(snapshot: snapshot),
            snapshot.key != FirebaseManager.shared.uid
            else { return }
        
        for observer in observers.values {
            observer.locationsDidUpdate(id: snapshot.key, location: location, updateType: type)
        }
    }
    
    func add(observer: LocationObserver) {
        observers[observer.identifier] = observer
    }
    
    func remove(observer: LocationObserver) {
        observers[observer.identifier] = nil
    }
}
