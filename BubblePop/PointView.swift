//
//  PointView.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import Foundation
import UIKit

class PointView: UILabel {
    
    var durationTimer: Timer?
    var duration: Int = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set default attributes
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.font = UIFont(name: "Fluo Gums", size: 20)

        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer: Timer) in
            self.updateView()
        })
    }
    
    func updateView() {
        // Animate label float upwards and fading slowly
        self.center.y -= 1
        alpha -= 0.02
        
        // Remove the label after a while
        if duration <= 0 {
            durationTimer?.invalidate()
            durationTimer =  nil
            
            self.removeFromSuperview()
        }
        else {
            duration -= 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
