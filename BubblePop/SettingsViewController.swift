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
    
    let dataStorage = DataStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let gameSettings = try dataStorage.loadGameSettings()
            gameTimeSlider.value = Float(toSliderValue(time: gameSettings.gameTime))
            maxBubblesSlider.value = Float(toSliderValue(limit: gameSettings.maxBubbles))
        } catch {
            let gameSettings = GameSettings()
            gameTimeSlider.value = Float(gameSettings.gameTime)
            maxBubblesSlider.value = Float(gameSettings.maxBubbles)
        }
        
        gameTimeSliderChanged(self)
        maxBubblesSliderChanged(self)
    }
    
    func toSliderValue(time: Int) -> Int {
        var value: Int = 0
        
        switch time {
        case 15:
            value = 0
        case 30:
            value = 1
        case 60:
            value = 2
        case 90:
            value = 3
        case 120:
            value = 4
        default:
            value = 2
        }
        return value
    }
    
    func toSliderValue(limit: Int) -> Int {
        var value: Int = 0
        
        switch limit {
        case 5:
            value = 0
        case 10:
            value = 1
        case 15:
            value = 2
        case 20:
            value = 3
        case 25:
            value = 4
        default:
            value = 2
        }
        return value
    }
    
    func toTimeValue(_ sliderValue: Int) -> Int {
        var time: Int = 0
        
        switch sliderValue {
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
        return time
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    @IBAction func gameTimeSliderChanged(_ sender: Any) {
        let time: Int = toTimeValue(Int(gameTimeSlider.value))
        
        gameTimeChosenLabel.text = timeFormatted(time)
        
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
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        let settings = GameSettings(gameTime: toTimeValue(Int(gameTimeSlider.value)), maxBubbles: Int(maxBubblesChosenLabel.text!)!)
        do {
            try dataStorage.saveData(settings: settings)
        } catch {
            print(error)
        }

//        performSegue(withIdentifier: "HomeViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "HomeViewSegue" {
//            let homeViewController = segue.destination as! HomeViewController
//            homeViewController.gameSettings = self.gameSettings
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
