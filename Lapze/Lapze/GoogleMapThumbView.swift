//
//  GoogleMapThumbView.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/7/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import Firebase

class GoogleMapThumbView: UIView {
    private let padding: Int = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(){
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(currentChampionNameLabel)
        self.addSubview(descriptionLabel)
        
        self.backgroundColor = ColorPalette.orangeThemeColor
        
        self.frame.size = CGSize(width: 150, height: 150)
        self.layer.cornerRadius = 10
        
        self.profileImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(padding)
            view.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        self.titleLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(padding)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(35.0)
        }
        
        self.currentChampionNameLabel.snp.makeConstraints { (view) in
            view.top.equalTo(titleLabel.snp.bottom)
            view.left.equalToSuperview().offset(padding)
            view.right.equalToSuperview().inset(padding)
            view.height.equalTo(35.0)
        }
        
        self.descriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(currentChampionNameLabel.snp.bottom)
            view.leading.equalToSuperview().offset(padding)
            view.trailing.equalToSuperview().inset(padding)
            view.bottom.equalToSuperview().inset(padding)
        }
    }
    
    func fillData(name: String) {
        titleLabel.text = name
    }
    
    let profileImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "010-man")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping 
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    var currentChampionNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
}
