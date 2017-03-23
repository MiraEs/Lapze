//
//  BottomActivityInfoView.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

class BottomActivityInfoView: UIView {
    private let padding: Int = 5
    private let fontSize = 20
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        
        self.addSubview(timeTitleLabel)
        self.addSubview(timeLabel)
        self.addSubview(distanceTitleLabel)
        self.addSubview(distanceLabel)
      
        timeTitleLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(padding)
            view.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(timeTitleLabel.snp.trailing).offset(padding)
            view.top.equalToSuperview().offset(padding)
        }
        
        distanceTitleLabel.snp.makeConstraints { (view) in
            view.top.equalTo(timeTitleLabel.snp.bottom).offset(padding)
            view.centerX.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(distanceTitleLabel.snp.trailing).offset(padding)
            view.top.equalTo(timeLabel.snp.bottom).offset(padding)
        }
    }
    
    private let timeTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .gray
        label.text = "time"
        return label
    }()
    
    private let distanceTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .gray
        label.text = "distance"
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.backgroundColor = .red
        return scrollView
    }()
    
    let timeLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.text = "00:00:00"
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.text = "2 miles"
        return label
    }()
}
