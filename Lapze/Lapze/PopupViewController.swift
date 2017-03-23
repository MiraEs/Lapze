//
//  PopupViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import CoreLocation

protocol JoinActivityDelegate {
    func joinChallenge(_ challenge: Challenge)
}

class PopupViewController: UIViewController {
    var segment: Int?
    var mapViewControllerState: MapViewControllerState = .events
    var delegate: JoinActivityDelegate?
    var userId: String = ""
    var challenge: Challenge?
    var activityId: String = ""
    var didCreateActivity = false
    var userLocation: CLLocation?
    var challengeLocation: Location?
    let locationStore = LocationStore.manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissView))
        view.addGestureRecognizer(tap)
        setupViewHierarchy()
        configureConstraints()
        setUpViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed {
            self.clearData()
        }
    }
    
    func dissmissView() {
        if didCreateActivity == false {
            dismissPopup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateButton()
    }
    
    //MARK: Interface Utilities
    private func setUpViewController(){
        switch mapViewControllerState{
        case .challenges:
            self.actionButton.backgroundColor = ColorPalette.orangeThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.orangeThemeColor
        case .events:
            self.actionButton.backgroundColor = ColorPalette.purpleThemeColor
            self.popupContainerView.backgroundColor = ColorPalette.purpleThemeColor
        }
    }
    
    func dismissPopup() {
        dismiss(animated: true, completion: nil)
    }
    
    func startActivity() {
        switch mapViewControllerState{
        case .challenges:
            if let id = FIRAuth.auth()?.currentUser?.uid {
                self.userId = id
            }
            if didCreateActivity == true {
                
                dismissPopup()
            }
            else {
                let location = Location(lat: self.challengeLocation!.latitude, long: self.challengeLocation!.longitude)
                if self.locationStore.isUserWithinRadius(userLocation:userLocation!, challengeLocation:location) {
                    print("User is within the radius")
                    if let challenge = challenge {
                        self.delegate?.joinChallenge(challenge)
                    }
                    dismissPopup()
                }
                else {
                    print("User is NOT within the radius")
                    let alertController = showAlert(title: "Unsuccessful!", message: "You're not at the challenge starting point!", useDefaultAction: true)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        case .events:
            print("Start event")
        }
    }
    
    func clearData() {
        self.challengeNameLabel.text = nil
        self.challengeDescriptionLabel.text = nil
        self.challengeStatsLabel.text = nil
    }
    
    //MARK: - setup
    private func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(blurView)
        self.blurView.addSubview(popupContainerView)
        self.blurView.addSubview(actionButton)
        self.popupContainerView.addSubview(profileImageView)
        self.popupContainerView.addSubview(challengeNameLabel)
        self.popupContainerView.addSubview(challengeDescriptionLabel)
        self.popupContainerView.addSubview(challengeStatsLabel)
    }
    
    private func configureConstraints() {
        popupContainerView.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.35)
            view.width.equalToSuperview().multipliedBy(0.75)
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.height.width.equalTo(100.0)
            view.centerY.equalTo(popupContainerView.snp.top)
            view.centerX.equalTo(popupContainerView)
        }
        
        challengeNameLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(70.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
        }
        
        challengeDescriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(challengeNameLabel.snp.bottom).offset(25.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
        }
        
        challengeStatsLabel.snp.makeConstraints { (view) in
            view.top.equalTo(challengeDescriptionLabel.snp.bottom).offset(20.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.bottom.equalToSuperview().inset(25.0)
        }
        
        actionButton.snp.makeConstraints { (view) in
            view.top.equalTo(self.view.snp.bottom)
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.11)
        }
    }
    
    private func animateButton(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.5)
        animator.addAnimations {
            self.actionButton.transform = CGAffineTransform(translationX: 0, y: -120)
        }
        animator.startAnimation()
    }
    
    //MARK: - Views
    lazy var popupContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40.0
        imageView.contentMode = .scaleAspectFill
        //imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    lazy var challengeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "", size: 40)
        return label
    }()
    
    lazy var challengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    lazy var challengeStatsLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.lightPurple
        label.font = UIFont(name: "Avenir Next", size: 25)
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(startActivity), for: .touchUpInside)
        return button
    }()
}

