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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set default attributes
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.font = UIFont(name: "Fluo Gums", size: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
