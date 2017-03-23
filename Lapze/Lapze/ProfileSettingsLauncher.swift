//
//  ProfileSettingsLauncher.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/11/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileSettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override init() {
        super.init()
        profileImagePicker.delegate = self
        profileImagePicker.dataSource = self
        profileImagePicker.register(ProfileSettingCell.self, forCellWithReuseIdentifier: cellId)
        
        for i in 0...60 {
            self.appProfileImages.append(String(i))
        }
    }
    
    let cellId = "cellId"
    
    var appProfileImages = [String]()
    let databaseRef = FIRDatabase.database().reference()
    let uid = FIRAuth.auth()?.currentUser?.uid
    private let userStore = UserStore.manager
    
    func showAvatars() {
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(blackView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
            blackView.addGestureRecognizer(tap)
            
            window.addSubview(profileImagePicker)
            
            let height: CGFloat = 200
            let y = window.frame.height - height
            profileImagePicker.frame = CGRect(x: 0, y: y, width: window.frame.width, height: 200)
            
            blackView.frame = window.frame
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.profileImagePicker.frame = CGRect(x: 0, y: y, width: self.profileImagePicker.frame.width, height: self.profileImagePicker.frame.height)
                
            }, completion: nil)
        }
    }
    
    func handleDismiss() {
        print("dismiss blackview")
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
            self.profileImagePicker.frame = CGRect(x: 0, y: window.frame.height, width: self.profileImagePicker.frame.width, height: self.profileImagePicker.frame.height)
            }
        }
    }
    //MARK: - Collection data flow
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appProfileImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileSettingCell
        
        cell.avatarImageView.image = UIImage(named: "\(appProfileImages[indexPath.row])")
        return cell
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let values = ["profilePic": "\(indexPath.row)"]
        userStore.updateUserData(values: values, child: nil)
        
    }
    //MARK: - Views
    internal var profileImagePicker: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    internal var blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.isUserInteractionEnabled = true
        return view
    }()
    
}
