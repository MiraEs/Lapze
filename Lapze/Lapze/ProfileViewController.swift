//
//  ProfileViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import Charts

protocol ProfileDelegate {
    func getActivityData(_ challenges: [Challenge])
}

enum Rank: String {
    case newbie = "Newbie"
    case benchwarmer = "Benchwarmer"
    case challenger = "Challenger"
    case warrior = "Warrior"
    case lapzer = "Lapzer"
    case olympian = "Olympian"
    case ultimateLapzer = "Ultimate Lapzer"
    case none = "none"
}

enum Badges: String {
    case firstChallenge = "First Challenge"
    case firstEvent = "First Event"
    case benchwarmer = "Benchwarmer"
    case challenger = "Challenger"
    case warrior = "Warrior"
    case lapzer = "Lapzer"
    case olympian = "Olympian"
    case ultimateLapzer = "Ultimate Lapzer"
    case baller = "Baller"
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProfileDelegate {
    
    let segments = ["Create Event", "Create Challenge"]
    let profileSetting = ProfileSettingsLauncher()
    let badgeTitles = ["Newbie","First Event","First Challenge","Benchwarmer","Challenger","Warrior", "Olympian", "Baller", "Lapzer", "Ultimate Lapzer"]
    
    let cellId = "badges"
    var userProfileImage = "0"
    
    let userStore = UserStore.manager
    var challengeRef: FIRDatabaseReference!
    let databaseRef = FIRDatabase.database().reference()
    private let challengeStore = ChallengeStore()
    var delegate: ProfileDelegate?
    
    var userChallenges: [Challenge] = []
    var userBadges: [String] = [] {
        didSet {
            self.badgesCollectionView.reloadData()
        }
    }
    var user: User! {
        didSet {
            checkRank()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "MY PROFILE"
        self.view.backgroundColor = .white
        setupViewHierarchy()
        configureConstraints()
        
        loadUser()
        getUserChallenges()
    }
    
    func getUserChallenges() {
        
        guard let uId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        challengeStore.getAllUserChallenges(userId: uId) { (challenges) in
            self.userChallenges = challenges
            
            //piechart data
            var activityDataDict = [String: Double]()
            for challenge in challenges {
                activityDataDict[challenge.type] = activityDataDict[challenge.type] ?? 1
            }
            self.setChart(userData: activityDataDict)
            self.getActivityData(challenges)
        }
    }
    
    func checkRank() {
        let theRank = getRank(user.challengeCount)
        if user?.rank != theRank.rawValue {
            userStore.updateRank(rank: theRank.rawValue)
        }
    }
    
    func getRank(_ challengeCount: Int) -> Rank {
        
        var rank = Rank.none
        
        switch challengeCount {
        case 0...10:
            rank = .newbie
        case 11...25:
            rank = .benchwarmer
        case 26...100:
            rank = .challenger
        case 101...250:
            rank = .lapzer
        case 251...500:
            rank = .olympian
        case 501...Int.max:
            rank = .ultimateLapzer
        default:
            rank = .none
        }
        
        return rank
    }
    
    //Test: set userchallenge data to implement badge count etc.
    func getActivityData(_ challenges: [Challenge]) {
        self.userChallenges = challenges
        
        for i in 0..<self.userChallenges.count {
            let values = ["\(i)": "\(self.badgeTitles)"]
            self.userStore.updateUserData(values: values, child: "badges")
        }
    }
    
    func loadUser() {
        guard let uId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        userStore.getUser(id: uId) { (user) in
            self.user = user
            self.usernameLabel.text = "\(user.name)"
            self.profileImageView.image = UIImage(named: "\(user.profilePic)")
            self.userRankLabel.text = user.rank
            
            if let badges = user.badges {
                self.userBadges = badges //access to global var
            }
        }
    }
    
    func logoutButtonTapped(sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
            let alertController = showAlert(title: "Logout Successful!", message: "You have logged out successfully. Please log back in if you want to enjoy the features.", useDefaultAction: true)
            //present(alertController, animated: true, completion: nil)
            
        }
        catch
        {
            let alertController = showAlert(title: "Logout Unsuccessul!", message: "Error occured. Please try again.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func pickAvatar() {
        profileSetting.showAvatars()
    }
    
    //MARK: - Collection data flow badges
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userBadges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BadgesCollectionViewCell
        
        cell.badgeImageView.image = UIImage(named: "\(badgeTitles[indexPath.row])")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentMainBadgeView()
    }
    
    func presentMainBadgeView() {
        let mbvc = MainBadgesViewController()
        self.present(mbvc, animated: true)
    }
    
    //MARK: - pie data
    func setChart(userData: [String: Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for (key, value) in userData {
            let dataEntry = PieChartDataEntry(value: Double(value), label: key, data: key as AnyObject)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<userData.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        
        self.pieChart.legend.enabled =  false
        self.pieChart.chartDescription?.text = ""
        self.pieChart.usePercentValuesEnabled = true
        self.pieChart.sizeToFit()
        
    }
    
    //MARK: - setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        badgesCollectionView.delegate = self
        badgesCollectionView.dataSource = self
        badgesCollectionView.register(BadgesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = logoutButton
        self.view.addSubview(topContainerView)
        self.topContainerView.addSubview(profileImageView)
        self.topContainerView.addSubview(usernameLabel)
        self.topContainerView.layer.insertSublayer(gradient, at: 0)
        
        self.view.addSubview(badgesCollectionView)
        self.view.addSubview(pieChart)
        self.view.addSubview(userRankLabel)
        self.view.addSubview(activitiesLabel)
        
    }
    
    func configureConstraints() {
        topContainerView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.4)
            view.top.equalToSuperview()
        }
        badgesCollectionView.snp.makeConstraints { (view) in
            view.left.right.equalToSuperview()
            view.height.equalTo(60)
            view.top.equalTo(topContainerView.snp.bottom)
        }
        profileImageView.snp.makeConstraints { (view) in
            view.width.height.equalTo(150.0)
            view.top.equalToSuperview().inset(8.0)
            view.centerX.equalToSuperview()
        }
        usernameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(8.0)
            view.centerX.equalToSuperview()
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        userRankLabel.snp.makeConstraints { (view) in
            view.top.equalTo(usernameLabel.snp.bottom).offset(8.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20.0)
        }
        
        activitiesLabel.snp.makeConstraints { (view) in
            view.top.equalTo(badgesCollectionView.snp.bottom).offset(8.0)
            view.left.equalToSuperview().offset(8.0)
            view.right.equalToSuperview().inset(8.0)
            view.height.equalTo(20)
        }
        
        pieChart.snp.makeConstraints { (view) in
            view.top.equalTo(badgesCollectionView.snp.bottom).offset(8.0)
            view.bottom.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.6)
            view.centerX.equalToSuperview()
        }
    }
    
    //MARK: - Views
    internal var winLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    internal var barStatusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    internal var barStatusOne: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    internal var pieChart: PieChartView = {
        let view = PieChartView()
        return view
    }()
    internal var topContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    internal lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor, UIColor.purple.cgColor]
        gradient.frame = CGRect(x: 0, y: 0, width: 500, height: 300)
        return gradient
    }()
    internal var badgesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    internal lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickAvatar))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    internal lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    internal lazy var userRankLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    internal lazy var activitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Activities"
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = UIFont(name: "Gill Sans", size: 20)
        return label
    }()
    internal lazy var challengesLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    internal lazy var logoutButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped(sender:)))
        return barButton
    }()
    
}
