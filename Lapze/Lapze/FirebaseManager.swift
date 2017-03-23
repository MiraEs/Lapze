//
//  FireBaseObserverManager.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import Firebase

enum UpdateType {
    case created
    case changed
    case removed
}

protocol FirebaseNodeObserver {
    func nodeDidUpdate(snapshot: FIRDataSnapshot, updateType type: UpdateType)
}

struct NodeObserverContainer {
    let childAddedHandler: UInt
    let childRemovedHandler: UInt
    let childChangedHandler: UInt
}

class FirebaseManager {
    static let shared: FirebaseManager  = FirebaseManager()
    let uid = FIRAuth.auth()?.currentUser?.uid
    private let databaseReference = FIRDatabase.database().reference()
    private var nodeObserversForIdentifier: [String: NodeObserverContainer] = [:]
    private init(){}
    
    fileprivate var nodeObservers: [FirebaseNodeObserver] = [EventStore.manager, LocationStore.manager]
    
    enum FirebaseNode: String{
        case location,event
    }
    
    func startObserving(node: FirebaseNode){
        let childRef = databaseReference.child(node.rawValue.capitalized)
        
        let childAddedhandler = childRef.observe(.childAdded, with: { (snapshot) in
            self.notifyObservers(snapshot: snapshot, updateType: .created)
        })
        
        let childChangedhandler = childRef.observe(.childChanged, with: { (snapshot) in
            self.notifyObservers(snapshot: snapshot, updateType: .changed)
        })
        
        let childRemovedhandler = childRef.observe(.childRemoved, with: { (snapshot) in
            self.notifyObservers(snapshot: snapshot, updateType: .removed)
        })
        
        nodeObserversForIdentifier[node.rawValue.capitalized] = NodeObserverContainer(childAddedHandler: childAddedhandler,
                                                                                      childRemovedHandler: childRemovedhandler,
                                                                                      childChangedHandler: childChangedhandler)
    }
    
    func stopObserving(node: FirebaseNode) {
        guard let nodeObserver = nodeObserversForIdentifier[node.rawValue.capitalized] else { return }
        databaseReference.removeObserver(withHandle: nodeObserver.childAddedHandler)
        databaseReference.removeObserver(withHandle: nodeObserver.childRemovedHandler)
        databaseReference.removeObserver(withHandle: nodeObserver.childChangedHandler)
    }
    
    func stopObserving(){
        databaseReference.removeAllObservers()
    }
    
    func addToFirebase(event: Event){
        let childRef = databaseReference.child("Event").child(uid!)
        childRef.updateChildValues(event.toJson()) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
            }else{
                print("Success posting event")
            }
        }
    }
    
    func removeEvent(){
        let childRef = databaseReference.child("Event").child(uid!)
        childRef.removeValue()
    }
    
    func removeUserLocation(){
        let childRef = databaseReference.child("Location").child(uid!)
        childRef.removeValue()
    }
    
    func updateFirebase(closure: (FIRDatabaseReference) -> Void) {
        closure(databaseReference)
    }
    
    func addToFirebase(location: Location){
        let childRef = databaseReference.child("Location").child(uid!)
        childRef.updateChildValues(location.toJson()) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
            }else{
                print("Success posting location")
            }
        }
    }
    
    func addToFirebase(challenge: Challenge){
        
    }
    
    private func getSnapshotValue(snapshot: FIRDataSnapshot)->[String:Double]?{
        return snapshot.value as? [String:Double]
    }
    
    fileprivate func notifyObservers(snapshot: FIRDataSnapshot, updateType type: UpdateType) {
        for observer in nodeObservers {
            observer.nodeDidUpdate(snapshot: snapshot, updateType: type)
        }
    }
}
