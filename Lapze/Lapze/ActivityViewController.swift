
//
//  ActivityViewController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/10/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit

import FirebaseDatabase
import CoreLocation
import Social


class ActivityViewController: UIViewController,EventViewControllerDelegate,ChallengeDelegate,JoinActivityDelegate, CLLocationManagerDelegate {
    private let mapViewController: MapViewController = MapViewController()
    private let topInfoView: TopActivityInfoView = TopActivityInfoView()
    private let bottomScrollInfoView: BottomActivityInfoScrollView = BottomActivityInfoScrollView()
    private var showInfoWindow: Bool = false
    private var timer: Timer = Timer()
    private var activityTime: Double = 0.0
    private let timeInterval:TimeInterval = 1
    private let timerEnd:TimeInterval = 0.0
    private var counter = 0
    private var didCreateActivity = false
    private var currentChallenge: Challenge?
    private let challengeStore: ChallengeStore = ChallengeStore()
    fileprivate var viewControllerState: MapViewControllerState = .events{
        didSet{
            updateInterface()
        }
    }
    
    //private var challengeFirebaseRef: FIRDatabaseReference?
    let locationManager = CLLocationManager() //test
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterface()
        setUpController()
        configureUserDefaults()
        
        //test
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(facebook))
    }
    
    //test
    
    
    func location() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    private func setUpController(){
        addMapViewController()
        setUpViews()
    }
    
    private func configureUserDefaults() {
        let userDefaults = UserDefaults.standard
        let isFirstTime = userDefaults.bool(forKey: "isNotFirstTime")
        
        if isFirstTime == false {
            userDefaults.set(true, forKey: "isNotFirstTime")
            createAnimationView()
            animateAddbuttonInfo(true)
        }
    }
    
    private func addMapViewController(){
        //Add Child view controller
        addChildViewController(mapViewController)
        
        //Add child view as Subview
        view.addSubview(mapViewController.view)
        
        //Configure child view
        mapViewController.view.frame = view.bounds
        
        //Notify child view controller
        mapViewController.didMove(toParentViewController: self)
        
        //Default map state
        mapViewController.updateMapState(state: .events)
        mapViewController.popVc.delegate = self
    }
    
    //MARK:- Map Utilties
    @objc private func changeMapState(sender: UISegmentedControl){
        guard let activity = MapViewControllerState(rawValue: sender.selectedSegmentIndex) else { return }
        
        viewControllerState = activity
        mapViewController.updateMapState(state: activity)
        mapViewController.popVc.mapViewControllerState = activity
    }
    
    //MARK:- User Interface Utilities
    private func updateInterface(){
        mapViewController.getAllChallenges()
        switch viewControllerState{
        case .events:
            addButton.backgroundColor = ColorPalette.purpleThemeColor
            topInfoView.backgroundColor = ColorPalette.greenThemeColor
            bottomScrollInfoView.actionButton.backgroundColor = ColorPalette.greenThemeColor
            navigationItem.title = "EVENTS"
            handleInfoInterface("EVENTS")
            
        case .challenges:
            addButton.backgroundColor = ColorPalette.orangeThemeColor
            topInfoView.backgroundColor = ColorPalette.orangeThemeColor
            bottomScrollInfoView.actionButton.backgroundColor = ColorPalette.orangeThemeColor
            navigationItem.title = "CHALLENGES"
            handleInfoInterface("CHALLENGES")
            
        }
        bottomScrollInfoView.actionButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    
    @objc private func handleInfoInterface(_ state: String) {
        switch state {
        case "EVENTS":
            addButtonInfoLabel.text = "Tap to create an EVENT"
            addButtonInfoLabel.backgroundColor = .purple
            infoThumbImageView.image = UIImage(named: "tap")
        case "CHALLENGES":
            addButtonInfoLabel.text = "Tap to create a CHALLENGE"
            addButtonInfoLabel.backgroundColor = .orange
            infoThumbImageView.image = UIImage(named: "crown")
        default:
            break
        }
    }
    
    
    @objc private func handlePostInfoInterface() {
        animateAddbuttonInfo(false)
        addButtonInfoLabel.removeFromSuperview()
        infoThumbImageView.removeFromSuperview()
    }
    
    @objc private func createActivityHandle(){
        switch viewControllerState {
        case .challenges:
            let challengeVc: CreateChallengeViewController = CreateChallengeViewController()
            navigationController?.pushViewController(challengeVc, animated: true)
            challengeVc.delegate = self
        case .events:
            let eventVc: CreateEventViewController = CreateEventViewController()
            navigationController?.pushViewController(eventVc, animated: true)
            eventVc.delegate = self
        }
    }
    
    @objc private func animateInfoWindow(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.7)
        showInfoWindow = !showInfoWindow
        switch showInfoWindow{
        case false:
            animator.addAnimations({
                self.topInfoView.transform = CGAffineTransform.identity
                self.bottomScrollInfoView.transform = CGAffineTransform.identity
                self.mapViewController.locateMeButton.transform = CGAffineTransform.identity
            }, delayFactor: 0.5)
            
        case true:
            animator.addAnimations ({
                self.bottomScrollInfoView.transform = CGAffineTransform(translationX: 0, y: -60)
                self.topInfoView.transform = CGAffineTransform(translationX: 0, y: 60)
                self.mapViewController.locateMeButton.transform = CGAffineTransform(translationX: 0, y: -60)
                
            }, delayFactor: 0.5)
            
            animator.addCompletion({ (position) in
                if position == .end{
                    self.animateBottomScrollInfoView()
                }
            })
        }
        
        animator.startAnimation()
        
    }
    
    private func animateBottomScrollInfoView(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1.5, dampingRatio: 0.9)
        
        animator.addAnimations{
            self.bottomScrollInfoView.contentOffset = CGPoint(x:(self.bottomScrollInfoView.actionButton.frame.width) * 0.9,y:0)
        }
        
        animator.addAnimations({
            self.bottomScrollInfoView.contentOffset = CGPoint(x: 0, y: 0)
        }, delayFactor: 0.7)
        
    }
    
    func animateAddbuttonInfo(_ isAnimating: Bool) {
        
        UIView.animate(withDuration: 1, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .repeat, animations: {
            //            self.infoThumbImageView.frame = CGRect(x: self.infoThumbImageView.frame.origin.x, y: -10, width: self.infoThumbImageView.frame.width, height: self.infoThumbImageView.frame.height)
            self.infoThumbImageView.frame = self.infoThumbImageView.frame.offsetBy(dx: 0, dy: -10)
        }, completion: nil)
        
        
        
    }
    
    //MARK:- Views
    private func setUpViews() {
        edgesForExtendedLayout = []
        self.view.addSubview(activitySegmentedControl)
        self.view.addSubview(addButton)
        self.view.addSubview(topInfoView)
        self.view.addSubview(bottomScrollInfoView)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePostInfoInterface))
        self.view.addGestureRecognizer(tap)
        
        addButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.height.equalTo(50)
            view.bottom.equalToSuperview().inset(10)
        }
        
        topInfoView.snp.makeConstraints { (view) in
            view.height.equalToSuperview().multipliedBy(0.11)
            view.trailing.leading.equalToSuperview()
            view.bottom.equalTo(self.view.snp.top)
        }
        
        bottomScrollInfoView.snp.makeConstraints { (view) in
            view.height.equalToSuperview().multipliedBy(0.11)
            view.trailing.leading.equalToSuperview()
            view.top.equalTo(self.view.snp.bottom)
        }
        
        bottomScrollInfoView.container.snp.makeConstraints { (view) in
            view.height.equalTo(self.view.snp.height).multipliedBy(0.11)
            view.width.equalTo(self.view.snp.width).multipliedBy(2)
        }
        
        activitySegmentedControl.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(25.0)
            view.width.equalToSuperview().multipliedBy(0.85)
            view.height.equalTo(30.0)
            view.centerX.equalToSuperview()
        }
        
    }
    
    func createAnimationView() {
        
        edgesForExtendedLayout = []
        
        self.view.addSubview(infoThumbImageView)
        self.view.addSubview(addButtonInfoLabel)
        
        infoThumbImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.size.equalTo(40)
            view.bottom.equalTo(addButton.snp.top).offset(-5)
        }
        addButtonInfoLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalTo(100.0)
            view.height.equalTo(50.0)
            view.bottom.equalToSuperview().inset(110.0)
        }
        self.view.layoutIfNeeded()
        
    }
    
    //MARK:- Event Delegate methods
    func startEvent(name: String, showUserLocation: Bool){
        topInfoView.titleLabel.text = "Your \(name) Session"
        bottomScrollInfoView.actionButton.setTitle("End Event", for: .normal)
        bottomScrollInfoView.actionButton.addTarget(nil, action: #selector(endEvent), for: .touchUpInside)
        mapViewController.startActivity()
        mapViewController.trackUserLocation = showUserLocation
        startTimer()
        animateInfoWindow()
    }
    
    @objc private func endEvent() {
        FirebaseManager.shared.removeEvent()
        FirebaseManager.shared.removeUserLocation()
        print("End event infoview")
        mapViewController.activityTime = Double(counter)
        mapViewController.endActivity()
        mapViewController.trackUserLocation = false
        stopTimer()
        animateInfoWindow()
    }
    
    //MARK:- Challenge Delegate Methods
    
    func challengeCreated(_ challenge: Challenge) {
        showPopUpController(with: challenge)
        mapViewController.popVc.challengeDescriptionLabel.text = "You just created a challenge!"
        mapViewController.didCreateActivity = true
        mapViewController.popVc.didCreateActivity = true
        self.didCreateActivity = true
        currentChallenge = challenge
        mapViewController.challenge = challenge
        topInfoView.titleLabel.text = challenge.name
        
    }
    
    @objc private func endChallenge(){
        print("End challenge infoview")
        mapViewController.activityTime = Double(counter)
        
        stopTimer()
        animateInfoWindow()
        showAlertSheet(title: "Keep this challenge", message: nil, acceptClosure: { (_) in
            print("Challenge saved")
            self.mapViewController.updateFirebase()
        }) { (_) in
            print("Challenge not saved")
            self.mapViewController.removeUserPath()
        }
        mapViewController.endActivity()
        self.didCreateActivity = false
    }
    
    @objc private func startChallenge(){
        bottomScrollInfoView.actionButton.setTitle("End Challenge", for: .normal)
        bottomScrollInfoView.actionButton.addTarget(nil, action: #selector(endChallenge), for: .touchUpInside)
        mapViewController.startActivity()
        animateInfoWindow()
        startTimer()
    }
    
    private func showPopUpController(with challenge: Challenge){
        mapViewController.popVc.challengeDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mapViewController.popVc.challenge = challenge
        mapViewController.popVc.modalTransitionStyle = .crossDissolve
        mapViewController.popVc.modalPresentationStyle = .overCurrentContext
        mapViewController.popVc.actionButton.addTarget(self, action: #selector(startChallenge), for: .touchUpInside)
        mapViewController.popVc.delegate = self
        present(mapViewController.popVc, animated: true, completion: nil)
    }
    
    //MARK:- Join Challenge Delegate method
    func joinChallenge(_ challenge: Challenge) {
        self.mapViewController.popVc.didCreateActivity = false
        self.mapViewController.didCreateActivity = false
        self.didCreateActivity = false
        currentChallenge = challenge
        topInfoView.titleLabel.text = challenge.name
        startChallenge()
        
    }
    
    //MARK:- Timer Utilities
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    private func stopTimer(){
        timer.invalidate()
        counter = 0
    }
    
    @objc private func tick(){
        counter += 1
        bottomScrollInfoView.infoView.timeLabel.text = timeString(TimeInterval(counter))
        bottomScrollInfoView.infoView.distanceLabel.text = String((mapViewController.distance/1609.34).roundTo(places: 2))
    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    private func showAlertSheet(title:String, message: String?, acceptClosure: ((UIAlertAction)->Void)?, reject: ((UIAlertAction)->Void)?){
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel, handler: reject)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler: acceptClosure)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Views
    fileprivate lazy var activitySegmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: ["Events","Challenges"])
        let font = UIFont.systemFont(ofSize: 14)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.tintColor = .white
        segmentedControl.addTarget(self, action: #selector(changeMapState(sender:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.backgroundColor = .black
        segmentedControl.alpha = 0.6
        segmentedControl.layer.borderColor = UIColor.white.cgColor
        
        return segmentedControl
    }()
    
    
    private lazy var addButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "add-1"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.snp.makeConstraints({ (view) in
            view.size.equalTo(CGSize(width: 30, height: 30))
        })
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.shadowRadius = 2
        button.backgroundColor = ColorPalette.purpleThemeColor
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(createActivityHandle), for: .touchUpInside)
        button.addTarget(self, action: #selector(handlePostInfoInterface), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButtonInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to create an Event"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.shadowOpacity = 0.4
        label.layer.shadowOffset = CGSize(width: 1, height: 5)
        label.layer.shadowRadius = 2
        label.numberOfLines = 2
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    private lazy var infoThumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "crownThumb")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}
