//
//  ScoreViewController.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var finalScoreLabel: UILabel!
    
    var playerName: String?
    var finalScore: Int!
    
    let dataStorage: DataStorage = DataStorage()
    var scoreboard: [Scoreboard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = playerName {
            finalScoreLabel.text = "Name is \(name) \n Final score is \(finalScore!)"
        }
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
