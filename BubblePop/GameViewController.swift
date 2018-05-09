//
//  GameViewController.swift
//  BubblePop
//
//  Created by Audwin on 23/4/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit
import AVFoundation // for sound player
import GameKit // for random number generator

/// Extension to support UILabel animations
extension UILabel {
    func fade() {
        self.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.alpha = 0.0 })
    }
    
    func blink() {
        self.alpha = 0.2
        UIView.animate(withDuration: 1.0, animations: { self.alpha = 1.0 },
                       completion: nil)
    }
    
}


class GameViewController: UIViewController {
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    let pink: UIColor = UIColor(red: 249/255.0, green: 174/255.0, blue: 200/255.0, alpha: 1)
    let customBlue: UIColor = UIColor(red: 113/255.0, green: 181/255.0, blue: 246/255.0, alpha: 1)
    
    var countdownTimer: Timer?
    var gameTimer: Timer?
    var audioPlayerBGM: AVAudioPlayer?
    var audioPlayerSFX: AVAudioPlayer?
    
    var gameSettings: GameSettings?
    var playerName: String?
    
    var countdownLeft: Int = 3
    var timeLeft: Int = 60
    var maxBubbles: Int = 15
    let removalRate: Int = 3
    
    var score: Int = 0
    var highScore: Int = 0

    var bubbles: [BubbleType] = []
    
//    var bubbles: [BubbleType] = [BubbleType(color: .red, points: 1),
//                                 BubbleType(color: .magenta, points: 2),
//                                 BubbleType(color: .green, points: 5),
//                                 BubbleType(color: .blue, points: 8),
//                                 BubbleType(color: .black, points: 10)]
    
    let randomSource: GKRandomSource = GKARC4RandomSource()
    
    var previousBubble: BubbleType?
    var isComboPoint: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bubbles.append(BubbleType(color: .red, points: 1))
        bubbles.append(BubbleType(color: pink, points: 2))
        bubbles.append(BubbleType(color: .green, points: 5))
        bubbles.append(BubbleType(color: customBlue, points: 8))
        bubbles.append(BubbleType(color: .black, points: 10))
        
        if let settings = gameSettings {
            timeLeft = settings.gameTime
            maxBubbles = settings.maxBubbles
        }
        
        timerLabel.text = timeFormatted(timeLeft)
        loadHighScore()
    }
    
    /// Method to load the high score from data storage
    func loadHighScore() {
        do {
            var scoreboard = try DataStorage().loadScoreboard()
            scoreboard.sort(by: { $0.score > $1.score })
            highScore = scoreboard[0].score
            highScoreLabel.text = String(highScore)
        } catch {
            highScore = 0
        }
    }
    
    func checkHighScore() {
        if score > highScore {
            highScore = score
            highScoreLabel.text = String(highScore)
        }
    }
    
    /// Method to update view during start countdown
    @objc func updateCountdown() {
        countdownLeft -= 1
        
        // Stop countdown, hide the countdown label and play BGM sound when time is zero (game starts)
        if countdownLeft <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            playSound(title: "popBGM", extensionCode: "mp3")
        }
        else {
            countdownLabel.text = String(countdownLeft)
            countdownLabel.fade()
            
            // Flash the countdown label
//            countdownLabel.isHidden = !countdownLabel.isHidden
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    /// Method to update view during play time
    @objc func updateGameTimer() {
        if countdownLeft <= 0 {
            if timeLeft <= 0 {
                gameTimer?.invalidate()
                gameTimer = nil
                
                audioPlayerBGM?.stop()
                
                self.performSegue(withIdentifier: "ScoreViewSegue", sender: self)
            }
            else {
                timeLeft -= 1
                
                // Emphasize there is short game time left
                if timeLeft <= 10 {
                    timerLabel.textColor = .red
                    timerLabel.font = UIFont.boldSystemFont(ofSize: timerLabel.font.pointSize)
                    timerLabel.blink()
                }
                
                timerLabel.text = timeFormatted(timeLeft)
                
                // Add more bubbles below the max number
                if bubbleCount() < maxBubbles {
                    let bubbleLimit = randomSource.nextInt(upperBound: (maxBubbles - bubbleCount()))
                    for _ in 0...bubbleLimit {
                        createBubble()
                    }
                }
                
                // Randomly remove bubbles
                
            }
        }

    }
    
    /// Method to create a new bubble randomly
    @objc func createBubble() {
        let randomX = CGFloat(randomSource.nextUniform()) * (self.view.frame.width-100)
        let randomY = CGFloat(randomSource.nextUniform()) * (self.view.frame.height-100)
        
        let newBubble = BubbleView(frame: CGRect(x: randomX, y: randomY, width: 80, height: 80))
        newBubble.bubbleType = randomBubbleType()
        setBubbleImage(of: newBubble)
        
        let validLocation = isValidLocation(of: newBubble)
        if validLocation {
            newBubble.tag = randomTag();
            
            newBubble.addTarget(self, action: #selector(bubblePopped(_:)), for: .touchDown)
            self.view.addSubview(newBubble)
            self.view.sendSubview(toBack: newBubble)
        }
    }
    
    /// Function to randomly decide the probability of appearance of bubble
    func randomBubbleType() -> BubbleType {
        var bag: [BubbleType] = []
        for _ in 1...40 {
            bag.append(bubbles[0])
        }
        for _ in 1...30 {
            bag.append(bubbles[1])
        }
        for _ in 1...15 {
            bag.append(bubbles[2])
        }
        for _ in 1...10 {
            bag.append(bubbles[3])
        }
        for _ in 1...5 {
            bag.append(bubbles[4])
        }
        
        let choice: Int = randomSource.nextInt(upperBound: bag.count)
        return bag[choice]
    }
    
    /// Method to set the image of the bubble
    func setBubbleImage(of newBubble: BubbleView) {
        if let color = newBubble.bubbleType?.color {
            switch color {
            case UIColor.red:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-red.png"), for: .normal)
            case pink:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-magenta.png"), for: .normal)
            case UIColor.green:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-green.png"), for: .normal)
            case customBlue:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-blue.png"), for: .normal)
            case UIColor.black:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-black.png"), for: .normal)
            default:
                break
            }
        }

    }
    
    /// Function to determine valid location of new bubble
    func isValidLocation(of newBubble: BubbleView) -> Bool {
        for subview in self.view.subviews {
            if let existingBubble = subview as? BubbleView {
                if existingBubble.frame.intersects(newBubble.frame) {
                    return false
                }
            }
        }
        return true
    }
    
    func randomTag() -> Int {
        // loop until a valid tag is available between range 1 to 50
        while true {
            let randomTag = Int(arc4random_uniform(50) + 1)
            guard let _ = self.view.viewWithTag(randomTag) else {
                return randomTag
            }
        }
    }
    
    /// Function to return the total of bubbles in view
    func bubbleCount() -> Int {
        var count: Int = 0
        for subview in self.view.subviews {
            if subview is BubbleView {
                count += 1
            }
        }
        return count
    }
    
    /// Function to calculate points earned
    /// If same colour bubbles are popped consecutively, bonus 1.5x the original point
    func pointsGained(from currentBubble: BubbleType) -> Int {
        if previousBubble?.color == currentBubble.color {
            let points = 1.5 * Double(currentBubble.points)
            isComboPoint = true
            return Int(round(points))
        }
        else {
            previousBubble = currentBubble
            isComboPoint = false
            return currentBubble.points
        }
    }
    
    /// Method to show the points gained after popping a bubble
    func showPointView(for currentBubble: BubbleView, gainedPoints: Int) {
        let pointView: PointView = PointView(frame: CGRect(x: currentBubble.frame.minX, y: currentBubble.frame.minY, width: 150, height: 150))
        
        pointView.textColor = currentBubble.bubbleType?.color
        
        if isComboPoint {
            pointView.text = "1.5X COMBO! \n +\(gainedPoints)"
            pointView.font = pointView.font.withSize(14)
            pointView.adjustsFontSizeToFitWidth = true
            pointView.sizeToFit()
        }
        else {
            pointView.text = "+\(gainedPoints)"
        }
        self.view.addSubview(pointView)
        
        // animate the points gained to float upwards and fading slowly
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            pointView.center.y = pointView.center.y - 50
            pointView.alpha = 0.02
        }) { (_) in
            pointView.removeFromSuperview()
        }

    }
    
    /// Event handler when a bubble is popped
    @IBAction func bubblePopped(_ sender: BubbleView) {
        playSound(title: "popSFX", extensionCode: "m4a")
        
        let points = pointsGained(from: sender.bubbleType!)
        showPointView(for: sender, gainedPoints: points)
        
        self.score += points
        
        scoreLabel.text = String(self.score)
        checkHighScore()
        
        sender.removeFromSuperview()
    }
    
    /// Method to play background music and bubble popped SFX
    func playSound(title: String, extensionCode: String) {
        guard let url = Bundle.main.url(forResource: title, withExtension: extensionCode) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Royalty free BGM credit: "Funny Plays" by SnowMusicStudio
            // Link: https://www.melodyloops.com/tracks/funny-plays/
            if (title == "popBGM") {
                audioPlayerBGM = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                guard let playerBGM = audioPlayerBGM else { return }
                playerBGM.play()
            }
            else if (title == "popSFX") {
                audioPlayerSFX = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                guard let playerSFX = audioPlayerSFX else { return }
                playerSFX.play()
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countdownLabel.fade()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove all bubbles from view
        for subview in self.view.subviews {
            if subview is BubbleView {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScoreViewSegue" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.playerName = self.playerName
            scoreViewController.finalScore = self.score
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

