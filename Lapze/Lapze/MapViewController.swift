//
//  MapViewController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/9/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseAuth

protocol MapStateProtocal {
    func updateMapState(state:MapViewControllerState)
}

public enum MapViewControllerState: Int {
    case events
    case challenges
}

class MapViewController: UIViewController,LocationConsuming,GMSMapViewDelegate,EventObserver,LocationObserver {
    
    let identifier: String = "MapViewController"
    
    fileprivate enum TrackingBehavior {
        case followWithPathMarking
        // case limitedFollow(radius:Int)
        case limitedFollow
        case none
    }
    
    fileprivate enum MarkerOption {
        case challenge
        case event
        case none
    }
    
    fileprivate var markerOption: MarkerOption = .event{
        didSet{
            updateMarkers()
        }
    }
    fileprivate var trackingBehavior: TrackingBehavior = .none
    fileprivate var userLocationMarker: GMSMarker?
    fileprivate var viewControllerState: MapViewControllerState = .events
    fileprivate var userCurrentLocation: CLLocation?{
        didSet{
            updateUserLocationMarker(location: userCurrentLocation!)
            
            if !userFound{
                goToUserLocation()
                userFound = !userFound
            }
        }
    }
    
    private var previousLocation: CLLocation?
    private var allChallenges: [Challenge] = []
    private var allEvents: [Event] = []{
        didSet{
            guard markerOption == .event else { return }
            self.showEventMarkers()
        }
    }
    private var userChampionshipChallenges: [String] = []
    private let challengeStore = ChallengeStore()
    private let userStore = UserStore.manager
    private var userFound: Bool = false
    let popVc: PopupViewController = PopupViewController()
    private let path: GMSMutablePath = GMSMutablePath()
    let challengePath = Path()
    let userPath = Path()
    var userPathArray: [Location] = []
    var distance: Double = 0.0
    var trackUserLocation: Bool = false
    var activityTime: Double = 0.0
    var challenge: Challenge?
    var didCreateActivity = true
    
    
    // MARK:_ Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        LocationManager.sharedManager.delegate = self
        googleMapView.delegate = self
        line.map = googleMapView
        FirebaseManager.shared.startObserving(node: .event)
        FirebaseManager.shared.startObserving(node: .location)
        GoogleMapManager.shared.manage(map: self.googleMapView)
        getAllChallenges()
        getAllEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EventStore.manager.add(observer: self)
        LocationStore.manager.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EventStore.manager.remove(observer: self)
        LocationStore.manager.remove(observer: self)
    }
    
    // MARK: Update views
    
    private func setUpViewController(){
        self.view.addSubview(googleMapView)
        self.view.addSubview(locateMeButton)
        
        googleMapView.snp.makeConstraints { (view) in
            view.trailing.leading.top.bottom.equalToSuperview()
        }
        
        locateMeButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(10)
            view.width.height.equalTo(40)
            view.bottom.equalToSuperview().inset(10)
        }
    }
    
    public func updateMapState(state: MapViewControllerState){
        viewControllerState = state
        switch state{
        case .challenges:
            markerOption = .challenge
        case .events:
            markerOption = .event
        }
    }
    
    public func hideAllMarkers(){
        GoogleMapManager.shared.hideAllMarkers()
    }
    
    //MARK:- Activity update
    public func startActivity(){
        
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        switch viewControllerState{
        case .challenges:
            trackingBehavior = .followWithPathMarking
            
        case .events:
            trackingBehavior = .limitedFollow//.limitedFollow(radius: 10)
        }
        userLocationMarker?.iconView = nil
        userStore.getUser(id: userId) { (user) in
            if let profileImage = self.resizeImage(user.profilePic) {
                self.userLocationMarker?.icon = profileImage
            }
        }
        
            if didCreateActivity == true {
                self.markerOption = .none
            }

        }
        
        public func endActivity(){
            switch viewControllerState{
            case .challenges:
                print("Challenges end")
                markerOption = .challenge
            case .events:
                markerOption = .event
            }
            userLocationMarker?.iconView = UserLocationMarker()
            userLocationMarker?.icon = nil
            trackingBehavior = .none
            
            removeUserPath()
        }
        
        func resizeImage(_ profilePic: String) -> UIImage? {
            let image = UIImage(named: profilePic)
            let width = 30.0
            let height = 30.0
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            
            image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
        
        public func updateFirebase() {
            
            guard let userId = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            
            guard userPathArray.count > 0 else {
                let alertController = showAlert(title: "OOPS", message: "Sorry, we coudn't locate you! Please try again!", useDefaultAction: true)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if didCreateActivity == true {
                challenge?.lat = userPathArray.first!.latitude
                challenge?.long = userPathArray.first!.longitude
                challenge?.path = userPathArray
                challenge?.timeToBeat = activityTime
                challenge?.distance = (distance/1609.34).roundTo(places: 2)
                challengeStore.add(challenge!)
                userStore.updateActivityCounts(activityType: "challengeCount")
            }
                
            else {
                let locationStore = LocationStore.manager
                if let path = challenge?.path, let endLocation = path.last {
                    if locationStore.isUserWithinRadius(userLocation: self.userCurrentLocation!, challengeLocation: endLocation) {
            
                        userStore.updateActivityCounts(activityType: "challengeCount")
                        
                        let currentDistance = (self.distance/1609.34).roundTo(places: 2)
                        if activityTime < (challenge?.timeToBeat!)! && (abs(currentDistance - (challenge?.distance!)!) < 0.05) {
                            
                            let currentDate = getCurrentDateString()
                            
                            challenge?.lastUpdated = currentDate
                            challenge?.champion = userId
                            challenge?.timeToBeat = activityTime
                            challenge?.distance = (distance/1609.34).roundTo(places: 2)
                            
                            challengeStore.add(challenge!)
                            let alertController = showAlert(title: "Great Job!", message: "You beat current champion. You hold the crown now!", useDefaultAction: true)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            let alertController = showAlert(title: "Nice Try!", message: "Sorry, your time didn't beat the current champion.", useDefaultAction: true)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    else {
                        let alertController = showAlert(title: "Unsuccessful!", message: "You're not at the challenge ending point!", useDefaultAction: true)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            distance = 0.0
            activityTime = 0.0
        }
        
        private func updateMarkers(){
            hideAllMarkers()
            switch markerOption {
            case .challenge:
                self.showChallengeMarkers(allChallenges)
            case .event:
                print("event markers")
                self.getAllEvents()
            case .none:
                print("show no markers")
            }
        }
        
        //MARK:- Challenge Utilities
        func getAllChallenges(){
            challengeStore.getAllChallenges { (challenges) in
                self.allChallenges = challenges
                self.userChampionshipChallenges = self.getUsersChampionships(challenges)
            }
        }
        
        private func getUsersChampionships(_ challenges: [Challenge]) -> [String] {
            
            guard let userId = FIRAuth.auth()?.currentUser?.uid else {
                return []
            }
            var challengeIds: [String] = []
            
            for challenge in challenges {
                if challenge.champion == userId {
                    challengeIds.append(challenge.id)
                }
            }
            return challengeIds
        }
        
        private func showChallengeMarkers(_ challenges: [Challenge]) {
            for challenge in challenges {
                if self.userChampionshipChallenges.contains(challenge.id) {
                    GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat!, long: challenge.long!, imageName: "crown")
                }
                else {
                    GoogleMapManager.shared.addMarker(id: challenge.id, lat: challenge.lat!, long: challenge.long!, imageName: challenge.type)
                }
            }
        }
        
        //MARK: - Event Utilities
        private func getAllEvents(){
            EventStore.manager.getAllCurrentEvents { (events) in
                self.allEvents = events
            }
        }
        
        private func showEventMarkers(){
            for event in allEvents{
                GoogleMapManager.shared.addMarker(event: event)
            }
        }
        
        func getEvent(id: String) -> Event?{
            for event in allEvents{
                if event.id == id{
                    return event
                }
            }
            return nil
        }
        
        //MARK: - EventObserver method
        func eventsDidUpdate(event: Event, updateType type: UpdateType) {
            switch type {
            case .removed:
                allEvents = allEvents.filter { $0.id != event.id }
                GoogleMapManager.shared.removeMarker(id: event.id, type: .event)
            case .changed:
                allEvents = allEvents.map { original in
                    if original.id == event.id {
                        return event
                    } else { return original }
                }
            case .created:
                allEvents.append(event)
            }
        }
        
        //MARK:- LocationObserver method
        
        func locationsDidUpdate(id: String, location: Location, updateType type: UpdateType) {
            switch type {
            case .removed:
                GoogleMapManager.shared.removeMarker(id: id, type: .profile)
            default:
                GoogleMapManager.shared.addMarker(id: id, location: location)
            }
        }
        
        //MARK:- LocationManager delegate methods
        func locationDidUpdate(newLocation: CLLocation) {
            userCurrentLocation = newLocation
            switch trackingBehavior{
            case .followWithPathMarking:
                trackDistance()
                addLocationToPathArray(newLocation)
                addPolyline(newLocation)
            case .limitedFollow:
                trackDistance()
                addUserLocationToFirebase(location: newLocation)
            case .none:
                print(trackingBehavior)
            }
        }
        
        func locationUnreachable() {
            print("Error getting location")
        }
        
        //MARK:- Location Utilities
        private func updateUserLocationMarker(location: CLLocation){
            let locationCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            if userLocationMarker == nil{
                userLocationMarker = GMSMarker(position: locationCordinate)
                userLocationMarker?.iconView = UserLocationMarker()
                userLocationMarker?.map = googleMapView
            }else{
                userLocationMarker?.position = locationCordinate
            }
        }
        
        @objc private func goToUserLocation(){
            if let location = userCurrentLocation{
                let clocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                googleMapView.animate(toLocation: clocation)
                googleMapView.animate(toZoom: 15)
            }
        }
        
        private func trackDistance(){
            let currentLocation = LocationManager.sharedManager.currentLocation
            if previousLocation != nil {
                let lastDistance = currentLocation?.distance(from: previousLocation as CLLocation!)
                distance += lastDistance!
            }
            previousLocation = currentLocation

        }
        
        private func addUserLocationToFirebase(location: CLLocation){
            let location = Location(location: location)
            switch trackUserLocation{
            case true:
                FirebaseManager.shared.addToFirebase(location: location)
            case false:
                break
            }
        }
        //MARK:- Polyline Utilities
        private func addPolyline(_ location: CLLocation){
            let cllcorddinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.path.add(cllcorddinate)
            self.line.path = path
        }
        
        private func addPolyline(_ location: Location){
            let cllcorddinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            self.path.add(cllcorddinate)
            self.line.path = path
        }
        private func addUserPath(){
            guard userPathArray.count > 0 else { return }
            let pathJsonArray = userPath.toJson(array: userPathArray)
        }

        private func addLocationToPathArray(_ location:CLLocation){
            let location = Location(location: location)
            userPathArray.append(location)
        }
        
        public func removeUserPath(){
            path.removeAllCoordinates()
            line.path = nil
            line.map = nil
            line.map = googleMapView
        }
        
        //MARK:- Google map delegate methods
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            guard marker != userLocationMarker else { return nil }
            
            let thumbView: GoogleMapThumbView = GoogleMapThumbView()
            thumbView.profileImageView.image = marker.icon
            marker.tracksInfoWindowChanges = true
            
            switch markerOption {
            case .event:
                guard let markerId = marker.title else {return nil}
                if let event = getEvent(id: markerId){
                    thumbView.titleLabel.text = event.type
                    thumbView.descriptionLabel.text = event.date

                    
                    UserStore.manager.getUser(id: markerId){ user in
                        thumbView.currentChampionNameLabel.text = (user.name) + " created this event"
                    }
                }
                //            LocationStore.manager.getPath(id: markerId, closure: { (locations) in
                //                for location in locations{
                //                    self.addPolyline(location)
                //                }
                //            })
                thumbView.backgroundColor = ColorPalette.purpleThemeColor
                
            case .challenge:
                thumbView.backgroundColor = ColorPalette.orangeThemeColor
                userPath.removePolyline()
                removeUserPath()
                if let id = marker.title {
                    challengeStore.getChallenge(id: id) { (challenge) in
                        self.userStore.getUser(id: challenge.champion, completion: { (user) in
                            thumbView.currentChampionNameLabel.text = ("Champion: \(user.name)")
                        })
                        
                        if self.userChampionshipChallenges.contains(id) {
                            thumbView.profileImageView.image = UIImage(named: "crown")
                        }
                        else {
                            thumbView.profileImageView.image = UIImage(named: challenge.type)
                        }
                        
                        thumbView.titleLabel.text = challenge.name
                        thumbView.descriptionLabel.text = ("\(challenge.type), \(challenge.lastUpdated) ")
                        if let challengePath = challenge.path {
                            let polyline = self.challengePath.getPolyline(challengePath)
                            polyline.strokeColor = .cyan
                            polyline.strokeWidth = 3.0
                            polyline.map = self.googleMapView
                        }
                    }
                }
                
            case .none:
                return nil
            }
            return thumbView
        }
    
        func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
            challengePath.removePolyline()
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            popVc.modalTransitionStyle = .crossDissolve
            popVc.modalPresentationStyle = .overCurrentContext
            
            switch viewControllerState{
            case .challenges:
                if let id = marker.title {
                    challengeStore.getChallenge(id: id) { (challenge) in
                        self.userStore.getUser(id: challenge.champion, completion: { (user) in
                            self.popVc.challengeDescriptionLabel.text = "\(user.name): Champion since \(challenge.lastUpdated)"
                            self.popVc.profileImageView.image = UIImage(named: (user.profilePic))
                        })
                        self.popVc.activityId = challenge.id
                        self.popVc.userLocation = LocationManager.sharedManager.currentLocation
                        self.popVc.challengeNameLabel.text = challenge.name
                        self.popVc.challengeStatsLabel.text = "\(challenge.type)"
                        if let lat = challenge.lat, let long = challenge.long {
                            self.popVc.challengeLocation = Location(lat: lat , long: long)
                        }
                        self.didCreateActivity = false
                        self.popVc.didCreateActivity = false
                        self.challenge = challenge
                        self.popVc.challenge = challenge
                    }
                }
                self.present(popVc, animated: true, completion: nil)
            case .events:
                print("Events")
            }
        }
        // MARK:- Views
        private let googleMapView: GMSMapView = {
            let mapview: GMSMapView = GMSMapView()
            mapview.translatesAutoresizingMaskIntoConstraints = false
            mapview.mapType = .normal
            mapview.isBuildingsEnabled = false
            
            do {
                if let styleURL = Bundle.main.url(forResource: "darkBlueStyle", withExtension: "json") {
                    mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
            return mapview
        }()
        
        private lazy var line: GMSPolyline = {
            let polyline: GMSPolyline = GMSPolyline()
            polyline.strokeColor = .green
            polyline.strokeWidth = 3
            polyline.geodesic = true
            return polyline
        }()
        
        let locateMeButton: UIButton = {
            let button: UIButton = UIButton()
            button.setImage(UIImage(named: "locate"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.imageView?.snp.makeConstraints({ (view) in
                view.size.equalTo(CGSize(width: 20, height: 20))
            })
            button.layer.shadowOpacity = 0.4
            button.layer.shadowOffset = CGSize(width: 1, height: 5)
            button.layer.shadowRadius = 2
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = 20
            button.addTarget(self, action: #selector(goToUserLocation), for: .touchUpInside)
            return button
        }()
    }
    
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let date = dateFormatter.string(from: Date())
        
        return date
}
