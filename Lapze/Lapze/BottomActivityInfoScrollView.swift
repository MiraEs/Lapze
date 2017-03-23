//
//  BottomActivityInfoScrollView.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/12/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

class BottomActivityInfoScrollView: UIScrollView {

   override init(frame: CGRect) {
        super.init(frame: frame)
    
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView(){
        self.addSubview(container)
        self.container.addSubview(actionButton)
        self.container.addSubview(infoView)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.isPagingEnabled = true
        
        container.snp.makeConstraints { (view) in
            view.top.bottom.trailing.leading.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { (view) in
            view.top.bottom.leading.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.5)
        }
        
        infoView.snp.makeConstraints { (view) in
            view.top.bottom.trailing.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    let actionButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Action", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.backgroundColor = .green
        return button
    }()
    
    let infoView: BottomActivityInfoView = {
        let infoView: BottomActivityInfoView = BottomActivityInfoView()
        infoView.backgroundColor = .purple
        return infoView
    }()
    
    let container: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .purple
        return view
    }()
    
}
