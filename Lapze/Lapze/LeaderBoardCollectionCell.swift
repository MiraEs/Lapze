//
//  LeaderBoardCollectionCell.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit

class LeaderBoardCollectionCell: BaseCell {
    override func setupViews() {
        super.setupViews()
        //backgroundColor = .gray
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(rankNumLabel)
        addSubview(winIcon)
        
        rankNumLabel.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(8.0)
            view.width.equalTo(26.0)
            view.centerY.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.width.height.equalTo(50.0)
            view.leading.equalTo(rankNumLabel.snp.trailing).offset(8.0)
        }
        
        nameLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(profileImageView.snp.trailing).offset(8.0)
            view.centerY.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalTo(20)
        }
        
        winIcon.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView).offset(-8)
            view.centerX.equalTo(profileImageView)
            view.size.equalTo(20)
        }
        
    }
    
    //MARK: - inits
    internal var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "question")
        imageView.layer.cornerRadius = 25.0
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .brown
        return imageView
    }()
    
    internal var winIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "leaderCrown")
        return imageView
    }()
    
    internal var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Gill Sans", size: 16)
        label.textColor = .gray
        return label
    }()
    
    internal var rankNumLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .orange
        label.font = UIFont(name: "Avenir Next", size: 22)
        return label
    }()
    
}
