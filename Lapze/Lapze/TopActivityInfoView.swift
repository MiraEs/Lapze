//
//  ActivityInfoView.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

class TopActivityInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
        }
    }
    
    let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
}
