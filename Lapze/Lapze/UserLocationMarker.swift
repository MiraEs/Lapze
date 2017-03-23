//
//  UserLocationMarker.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/9/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit

class UserLocationMarker: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(){
        
        self.backgroundColor = ColorPalette.flatRed
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.layer.shadowRadius = 2
        
        self.snp.makeConstraints { (view) in
            view.height.width.equalTo(20)
        }
        
        self.layer.add(fadeAnimation(), forKey: nil)
//        let pulse = Pulse()
//        pulse.position = self.center
//        self.layer.insertSublayer(pulse, below: self.layer)
    }
    
    private func fadeAnimation()-> CABasicAnimation{
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.autoreverses = true
        animation.duration = 3
        animation.fromValue = 0.3
        animation.toValue = 0.9
        animation.repeatCount = CFloat.infinity
        animation.isRemovedOnCompletion = false
        return animation
    }
    
}
