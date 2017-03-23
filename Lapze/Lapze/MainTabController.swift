//
//  MainTabController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/8/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class MainTabController: UITabBarController{
    
    private let profileVC = UINavigationController(rootViewController: ProfileViewController())
    private let activityVC = UINavigationController(rootViewController: ActivityViewController())
    private let leaderBoardVc = UINavigationController(rootViewController: LeaderBoardViewController())
    private let eventVC = UINavigationController(rootViewController: EventsViewController())
    private lazy var dummyViewController: UIViewController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // checkForUserStatus()
        setDefaultViewController()
        
    }
    override func viewDidAppear(_ animated: Bool) {
      checkForUserStatus()
    }
    
    private func checkForUserStatus(){
        _ = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user == nil{
                self.perform(#selector(self.showLogin), with: nil, afterDelay: 0.01)
            }else if !self.userLocationPermissionGranted {
                  self.perform(#selector(self.showLocationNeed), with: nil, afterDelay: 0.01)
            }else{
                self.setUpTabBar()
            }
        })
        
    }
    
    fileprivate var userLocationPermissionGranted: Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        return authorizationStatus == .authorizedWhenInUse
    }
    
    @objc private func showLogin(){
        let loginVC = LoginViewController()//UINavigationController(rootViewController: LoginViewController())
        setDefaultViewController()
        present(loginVC, animated: true, completion: nil)
    }
    
    @objc private func showLocationNeed(){
        let locationNeededVC = LocationNeededViewController()
        self.present(locationNeededVC, animated: true, completion: nil)
        locationNeededVC.onLocationPermissionsGranted = { [weak self] in
            self?.setUpTabBar()
        }
    }
    
    private func setUpTabBar(){
        
        self.viewControllers = [activityVC, profileVC, leaderBoardVc]
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "Profile"), selectedImage: #imageLiteral(resourceName: "Profile"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab
        
        let leaderBoardTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "011-crown"), selectedImage: #imageLiteral(resourceName: "011-crown"))
        leaderBoardTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        leaderBoardVc.tabBarItem = leaderBoardTab
        
        let activityTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        activityTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        activityVC.tabBarItem = activityTab
        
        self.tabBar.backgroundColor = ColorPalette.greenThemeColor
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = ColorPalette.lightPurple
        
        self.selectedIndex = 0
    }
    
    private func setDefaultViewController(){
        dummyViewController.view.backgroundColor = ColorPalette.greenThemeColor
        self.viewControllers = [dummyViewController]
    }
}
