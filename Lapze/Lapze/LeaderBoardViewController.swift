//
//  LeaderBoardViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import Firebase

class LeaderBoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "leaderCell"
    let userStore = UserStore.manager
    
    var users: [User] = [] {
        didSet {
           users.sort { (a, b) -> Bool in
                (a.challengeCount + a.eventCount) > (b.challengeCount+b.eventCount)
            }
            self.leaderBoardCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = "LEADERBOARD"
        setup()
        loadUsers()
        
    }
    
    //MARK: - Utilities
    func setup() {
        self.view.addSubview(topContainerView)
        self.view.addSubview(leaderBoardCollectionView)
        
        leaderBoardCollectionView.delegate = self
        leaderBoardCollectionView.dataSource = self
        leaderBoardCollectionView.register(LeaderBoardCollectionCell.self, forCellWithReuseIdentifier: cellId)
        
        topContainerView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(100)
        }
        
        leaderBoardCollectionView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.height.equalTo(600)
            //view.top.equalTo(showBadgesButton.snp.bottom)
            view.bottom.equalToSuperview()
        }
    }
    
    func loadUsers() {
        userStore.getAllUsers { (users) in
            self.users = users
        }
    }
    
    func showBadges() {
        self.navigationController?.pushViewController(MainBadgesViewController(), animated: true)
    }
    
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LeaderBoardCollectionCell
        
        //hack test
        cell.rankNumLabel.text = "\(Int(indexPath.row) + 1)"

        //^^ delete NSTextattachment
        let nameString = "\(users[indexPath.row].name) the \(users[indexPath.row].rank) with \(users[indexPath.row].challengeCount) wins "
        cell.nameLabel.text = nameString
        cell.profileImageView.image = UIImage(named: "\(self.users[indexPath.row].profilePic)")
        
        if indexPath.row != 0 {
            cell.winIcon.image = nil
        }
        
        return cell
    }
    
   
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: leaderBoardCollectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
    //MARK: - views
    internal var leaderBoardCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    internal let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
  
    
}
