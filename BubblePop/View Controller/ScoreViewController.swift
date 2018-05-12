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
    let maxRowsToShow: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load and sort the scoreboard
        do {
            scoreboard = try dataStorage.loadScoreboard()
        } catch {
            print("Error loading scoreboard")
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
            scoreboardTableView.reloadData()
            
            // Save scoreboard
            do {
                try dataStorage.saveData(scores: scoreboard)
            } catch {
                print("Error saving scoreboard")
            }
            
        }
        else {
            playerNameLabel.text = "High Scores"
            finalScoreLabel.text = ""
        }
        
    }
    
    func sortScores() {
        scoreboard.sort(by: { $0.score > $1.score })
    }
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        sender.shrink()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    /// Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(scoreboard.count, maxRowsToShow)
    }
    
    /// Format the row cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameScoreCell", for: indexPath)
        
        let nameLabelCell: UILabel = cell.viewWithTag(1) as! UILabel
        let scoreLabelCell: UILabel = cell.viewWithTag(2) as! UILabel
        
        nameLabelCell.text = "\(indexPath.row + 1). \(scoreboard[indexPath.row].name)"
        scoreLabelCell.text = ": \(scoreboard[indexPath.row].score) points"
        
        // alternate the cell background color
        if indexPath.row % 2 == 1 {
            let lightCyan = UIColor(red: 224/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
            cell.backgroundColor = lightCyan
        }
        else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top 10 Ranks"
    }
}
