//
//  GoogleMarker.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import GoogleMaps

class GoogleMapManager{
    static let shared: GoogleMapManager = GoogleMapManager()
    private var map: GMSMapView?
    private init(){}
    
    private var dict: [String: GMSMarker] = [:]
    private var eventMarkerDic: [String:GMSMarker] = [:]
    private var userLocationMarkerDic: [String:GMSMarker] = [:]
    
    enum MarkerIconType{
        case profile, event
    }
    
    func manage(map: GMSMapView) {
        self.map = map
    }
    
    func addMarker(id: String, with locationDict:[String:Double]) {
        guard getMarker(id: id) == nil else { return }
        
        if let lat = locationDict["lat"], let long = locationDict["long"] {
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            self.dict[id] = marker
            marker.map = map
            marker.icon = UIImage(named: "010-man")
            marker.title = id
        }
    }
    
    func addMarker(id: String, lat: Double, long: Double, imageName: String) {
        if dict[id] == nil{
            let cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker(position: cllocation)
            self.dict[id] = marker
            marker.map = map
            let image = UIImage(named: ("\(imageName)Thumb"))
            marker.icon = image
            marker.title = id
        }else{
            let markerTest = getMarker(id: id)
            markerTest?.position.latitude = lat
            markerTest?.position.longitude = long
        }
    }
    
    func addMarker(event: Event) {
        guard event.id != FirebaseManager.shared.uid,
            eventMarkerDic[event.id] == nil else { return }
        let cllocation = CLLocationCoordinate2D(latitude: event.location.latitude,
                                                longitude: event.location.longitude)
        let marker = GMSMarker(position: cllocation)
        self.eventMarkerDic[event.id] = marker
        marker.map = map
        marker.icon = UIImage.eventIcon(named: event.type.capitalized)
        marker.title = event.id
    }
    
    func addMarker(id: String, location: Location){
        UserStore.manager.getUser(id: id){ user in
            let cllocation = CLLocationCoordinate2D(latitude: location.latitude,
                                                    longitude: location.longitude)
            self.userLocationMarkerDic[id]?.map = nil
            self.userLocationMarkerDic[id] = nil
            let marker = GMSMarker(position: cllocation)
            self.userLocationMarkerDic[id] = marker
            let profilePic = UIImage.profileIcon(named: (user.profilePic))
            marker.map = self.map
            marker.icon = profilePic
        }
    }
    
    func addMarker(id: String, marker:GMSMarker) {
        self.dict[id] = marker
        marker.map = map
    }
    
    func getMarker(id:String) -> GMSMarker? {
        return dict[id]
    }
    
    func removeMarker(id:String, type: MarkerIconType) {
        
        switch type{
        case .event:
            eventMarkerDic[id]?.map = nil
            eventMarkerDic[id] = nil
        case .profile:
            userLocationMarkerDic[id]?.map = nil
            userLocationMarkerDic[id] = nil
        }
        
        dict[id]?.map = nil
        dict[id] = nil
        
    }
    
    func allMarkers() -> [String:GMSMarker] {
        return dict
    }
    
    func hideAllMarkers() {
        for marker in self.dict{
            marker.value.map = nil
        }
        for marker in self.eventMarkerDic {
            marker.value.map = nil
        }
        self.dict = [:]
        self.eventMarkerDic = [:]
    }
}

extension UIImage {
    class func profileIcon(named name: String, iconSize: CGSize = CGSize(width: 30, height: 30)) -> UIImage?{
        guard let image = UIImage(named: name) else { return nil }
        UIGraphicsBeginImageContext(iconSize)
        image.draw(in: CGRect(x :0, y:0, width: iconSize.width, height: iconSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func eventIcon(named name: String, iconSize: CGSize = CGSize(width: 30, height: 30)) -> UIImage?{
        guard let image = UIImage(named: name + "Thumb") else { return nil }
        UIGraphicsBeginImageContext(iconSize)
        image.draw(in: CGRect(x :0, y:0, width: iconSize.width, height: iconSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


