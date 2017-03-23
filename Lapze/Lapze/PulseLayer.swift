//
//  PulseLayer.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/13/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import Foundation
import UIKit

class Pulse:CALayer{
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(){
        super.init()
        
        DispatchQueue.main.async {
            self.add(self.animationGroup(), forKey: nil)
            self.backgroundColor = UIColor.cyan.cgColor
        }
    }
    
    private func createScaleAnimation()-> CABasicAnimation{
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 10
        scaleAnimation.duration = 1.5
        scaleAnimation.repeatCount = Float(CGFloat.infinity)
        return scaleAnimation
    }
    
    private func createOpacityAnimation()-> CAKeyframeAnimation{
        let opacityAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4,0.8,1,0]
        opacityAnimation.keyTimes = [0,0.2,1]
        return opacityAnimation
    }
    
    private func animationGroup()->CAAnimationGroup{
        let group = CAAnimationGroup()
        group.duration = 3
        group.repeatCount = Float(CGFloat.infinity)
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        group.animations = [createOpacityAnimation(),createScaleAnimation()]
        
        return group
    }
}
