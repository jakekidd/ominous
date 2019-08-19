//
//  BeepCircleView.swift
//  OminousBeepingApp
//
//  Created by Jake on 7/22/19.
//  Copyright © 2019 jake. All rights reserved.
//

import UIKit

class BeepCircleView: UIView {
    
    private(set) var isAnimating: Bool = false
    
    private let kNumRings: Int = 3
    
    private lazy var _circleLayers: [CAShapeLayer] = {
        var layers: [CAShapeLayer] = []
        
        let ringWidth = (self.frame.width / CGFloat(kNumRings + 4))
        let centerDiameter = ringWidth * 1.26
        let centerPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.5), radius: centerDiameter, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        let centerLayer = CAShapeLayer()
        centerLayer.fillColor = UIColor.appRed.cgColor
        centerLayer.path = centerPath.cgPath
        layers.append(centerLayer)
        
        for n in 1...kNumRings {
            let path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.5), radius: ringWidth * CGFloat(1 + n), startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.appRed.cgColor
            shapeLayer.lineWidth = ringWidth * 0.6
            shapeLayer.fillColor = nil
            layers.append(shapeLayer)
        }
        
        return layers
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.frame.width * 1.2).isActive = true
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        for layer in _circleLayers {
            self.layer.addSublayer(layer)
        }
        
//        self.hideLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Show all the layers at half opacity.
    public func showLayers() {
        for layer in _circleLayers {
            layer.opacity = 1.0
        }
    }
    
    /// Make all rings invisible.
    private func hideLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for layer in _circleLayers {
            layer.opacity = 0.0
        }
        CATransaction.commit()
    }
    
    /// Radiate outwards once.
    public func beep(speed: Double = 0.5) {
        if !isAnimating {
            isAnimating = true
            hideLayers()
            
            let interval: Double = speed / Double(kNumRings + 2)
            var n = 0
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
                guard n < self._circleLayers.count else {
                    timer.invalidate()
                    
                    // Make second to last ring invisible.
                    if self._circleLayers.count > 1 {
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        self._circleLayers[self._circleLayers.count - 2].opacity = 0.0
                        CATransaction.commit()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: {
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        self._circleLayers[self._circleLayers.count - 1].opacity = 0.0
                        CATransaction.commit()
                        self.isAnimating = false
                    })
                    return
                }
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self._circleLayers[n].opacity = 1.0
                if n > 1 {
                    for i in 0..<(n - 1) {
                        self._circleLayers[i].opacity = 0.0
                    }
                }
                CATransaction.commit()
                
                n += 1
            }
        }
    }
    
}
