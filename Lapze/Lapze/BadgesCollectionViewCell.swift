//
//  BadgesCollectionViewCell.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class BadgesCollectionViewCell: BaseCell {
    override func setupViews() {
        super.setupViews()
        
        addSubview(badgeImageView)
        addSubview(badgeLabel)
        
        badgeImageView.snp.makeConstraints { (view) in
            view.size.equalToSuperview()
        }
        
        badgeLabel.snp.makeConstraints { (view) in
            view.top.equalTo(badgeImageView.snp.bottom).offset(5)
            view.width.equalTo(badgeImageView.snp.width)
            view.height.equalTo(15)
        }
    }
    
    
    //MARK: - inits
    internal var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "question")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    internal var badgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}
