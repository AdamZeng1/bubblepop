//
//  ScoreViewController.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var scoreboardTableView: UITableView!
    
    var playerName: String?
    var finalScore: Int!
    
    let dataStorage: DataStorage = DataStorage()
    var scoreboard: [Scoreboard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            scoreboard = try dataStorage.loadScoreboard()
        } catch {
            print("Loading scoreboard error")
        }
        
        sortScores()
        
        scoreboardTableView.dataSource = self
        scoreboardTableView.delegate = self
        
        if let name = playerName {
            playerNameLabel.text = name
            finalScoreLabel.text = "Final Score: \(finalScore!)"
            
            let newEntry = Scoreboard(name: name, score: finalScore)
            
            scoreboard.append(newEntry)
            sortScores()
        }
        else {
            playerNameLabel.text = ""
            finalScoreLabel.text = ""
        }
        
    }
    
    func numberOfSections(in scoreboardTableView: UITableView) -> Int {
        return 1
    }
    
    func sortScores() {
        scoreboard.sort(by: { $0.score > $1.score })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
