//
//  ScoreboardViewController.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var finalScoreLabel: UILabel!
    
    var finalScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finalScoreLabel.text = "Final score is \(finalScore!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
