//
//  ProfileSettingCell.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/11/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


class ProfileSettingCell: BaseCell {
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .blue
        
        addSubview(avatarImageView)
        configure()
    }
    
    //MARK: - setup
    func configure() {
        
        avatarImageView.snp.makeConstraints { (view) in
            view.size.equalToSuperview()
        }
    }
    
    //MARK: - inits
    internal var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "004-boy")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
