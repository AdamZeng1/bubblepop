//
//  SettingsViewController.swift
//  BubblePop
//
//  Created by Audwin on 7/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var gameTimeChosenLabel: UILabel!
    @IBOutlet weak var gameTimeSlider: UISlider!
    @IBOutlet weak var minGameTimeLabel: UILabel!
    @IBOutlet weak var maxGameTimeLabel: UILabel!
    
    
    @IBOutlet weak var maxBubblesChosenLabel: UILabel!
    @IBOutlet weak var maxBubblesSlider: UISlider!
    @IBOutlet weak var minBubblesLabel: UILabel!
    @IBOutlet weak var maxBubblesLabel: UILabel!
    
    var gameSettings = GameSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func gameTimeSliderChanged(_ sender: Any) {
        let value: Int = Int(gameTimeSlider.value)
        var time: Int = 0
        
        switch value {
        case 0:
            time = 15
        case 1:
            time = 30
        case 2:
            time = 60
        case 3:
            time = 90
        case 4:
            time = 120
        default:
            time = 60
        }
        
        gameTimeChosenLabel.text = String(time)
        
//        gameSettings?.gameTime = time
//        gameSettings.setGameTime(to: time)
    }
    
    @IBAction func maxBubblesSliderChanged(_ sender: Any) {
        let value: Int = Int(maxBubblesSlider.value)
        var limit: Int = 0
        
        switch value {
        case 0:
            limit = 5
        case 1:
            limit = 10
        case 2:
            limit = 15
        case 3:
            limit = 20
        case 4:
            limit = 25
        default:
            limit = 15
        }
        
        maxBubblesChosenLabel.text = String(limit)
        
//        gameSettings?.maxBubbles = limit
//        gameSettings.setMaxBubbles(to: limit)
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeViewSegue" {
            let homeViewController = segue.destination as! HomeViewController
            homeViewController.gameSettings = self.gameSettings
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
