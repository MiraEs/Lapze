//
//  EventStore.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/16/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import Firebase

protocol EventObserver {
    var identifier: String { get }
    func eventsDidUpdate(event: Event, updateType type: UpdateType)
}

class EventStore: FirebaseNodeObserver {
    static let manager: EventStore = EventStore()
    private init(){}
    fileprivate var observers: [String: EventObserver] = [:]
    var delegate: EventObserver?
    
    private var allEventsArray: [Event] = []
    private var eventStoreDict: [String: Event] = [:]
    
    func getAllCurrentEvents(closure:@escaping ([Event])->Void){
        var returnArray: [Event] = []
        FirebaseManager.shared.updateFirebase { (ref) in
            let childRef = ref.child("Event")
            childRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children{
                    dump(child)
                    guard  let snap = child as? FIRDataSnapshot else { return }
                    
                    if let event = self.createEvent(snapshot: snap){
                        returnArray.append(event)
                        //self.eventStoreDict[event.id] = event
                    
                    }
                    self.allEventsArray = returnArray
                }
                closure(returnArray)
            })
        }
    }
    
    func createEvent(snapshot: FIRDataSnapshot) -> Event? {
        guard let valueDic = snapshot.value as? [String:Any] else { return nil }
        
        if let type = valueDic["type"] as? String,
            let date = valueDic["date"] as? String,
            let locationDic = valueDic["location"] as? [String:Double]{
            guard let lat = locationDic["lat"], let long = locationDic["long"] else { return nil }
            
            let location = Location(lat: lat, long: long)
            let event = Event(id: snapshot.key, type: type, date: date, location: location)
            return event
        }
        return nil
    }
    
    func getEvent(id: String) -> Event?{
        for event in allEventsArray{
            if event.id == id{
                return event
            }
        }
        return nil
    }
    
    func add(observer: EventObserver) {
        observers[observer.identifier] = observer
    }
    
    func remove(observer: EventObserver) {
        observers[observer.identifier] = nil
    }
    
    func updateStore(){
        getAllCurrentEvents { (events) in
            self.allEventsArray = events
        }
    }
    
    func nodeDidUpdate(snapshot: FIRDataSnapshot, updateType type: UpdateType) {
        guard let event = createEvent(snapshot: snapshot) else { return }
        for observer in observers.values {
            observer.eventsDidUpdate(event: event, updateType: type)
        }
    }
}
