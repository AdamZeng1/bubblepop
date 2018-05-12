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

extension UILabel {
    /// Fading animation
    func fade() {
        self.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.alpha = 0.0 })
    }
    
    /// Blinking animation
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
    
    // Custom UIColors
    let pink: UIColor = UIColor(red: 249/255.0, green: 174/255.0, blue: 200/255.0, alpha: 1)
    let customBlue: UIColor = UIColor(red: 113/255.0, green: 181/255.0, blue: 246/255.0, alpha: 1)
    
    var countdownTimer: Timer?
    var gameTimer: Timer?
    var bubbleTimer: Timer?
    
    var audioPlayerBGM: AVAudioPlayer?
    var audioPlayerSFX: AVAudioPlayer?
    
    var gameSettings: GameSettings?
    var playerName: String?
    
    var countdownLeft: Int = 3
    var timeLeft: Int = 60
    var maxBubbles: Int = 15
    let removalRate: Int = 3
    
    var changeSpeedTime: Int = 0
    var originalTime: Int = 0
    var floatSpeed: CGFloat = 1.0
    
    var score: Int = 0
    var highScore: Int = 0

    var bubbles: [BubbleType] = []
    var previousBubble: BubbleType?
    var isComboPoint: Bool = false
    
    let randomSource: GKRandomSource = GKARC4RandomSource()
    
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
    
    /// Method to update high score if current score is higher
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
            
            countdownLabel.isHidden = true
            playSound(title: "popBGM", extensionCode: "mp3")
        }
        else {
            countdownLabel.text = String(countdownLeft)
            countdownLabel.fade()
        }
    }
    
    /// Method to update view during play time
    @objc func updateGameTimer() {
        guard countdownLeft <= 0 else { return }
        
        if timeLeft <= 0 {
            gameTimer?.invalidate()
            gameTimer = nil
            
            bubbleTimer?.invalidate()
            bubbleTimer = nil
            
            audioPlayerBGM?.stop()
            
            self.performSegue(withIdentifier: "ScoreViewSegue", sender: self)
        }
        else {
            // scale new floating speed to original time
            let newSpeedTime = self.changeSpeedTime - (self.originalTime / 6)
            
            // increase speed every certain time:
            // [originalTime : changeSpeedTime/interval]
            // [15s:2s, 30s:5s, 60s:10s, 90s:15s, 120s:20s]
            if timeLeft == changeSpeedTime {
                self.changeSpeedTime = newSpeedTime
                self.floatSpeed += 0.05
            }
            
            timeLeft -= 1
            
            if timeLeft <= 10 {
                emphasizeTimeUp()
            }
            timerLabel.text = timeFormatted(timeLeft)
            
            addMoreBubbles()
            removeRandomBubbles()
        }
    }
    
    /// Method to add more bubbles below the max number
    func addMoreBubbles() {
        if bubbleCount() < maxBubbles {
            let bubbleLimit = randomSource.nextInt(upperBound: (maxBubbles - bubbleCount()))
            for _ in 0...bubbleLimit {
                createBubble()
            }
        }
    }
    
    /// Method to randomly remove bubbles periodically
    func removeRandomBubbles() {
        guard timeLeft % removalRate == 0 else { return }
        
        var removalCount = randomSource.nextInt(upperBound: bubbleCount())
        for subview in self.view.subviews {
            if subview.tag > 0 {
                if removalCount > 0 {
                    removeBubble(subview as! BubbleView)
                    removalCount -= 1
                }
                else {
                    break
                }
            }
        }
    }
    
    /// Function to format the time text
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    /// Method to emphasize not much game time left
    func emphasizeTimeUp() {
        timerLabel.textColor = .red
        timerLabel.font = UIFont.boldSystemFont(ofSize: timerLabel.font.pointSize)
        timerLabel.blink()
    }
    
    /// Method to animate bubbles float and remove them when off the view
    @objc func updateBubbleView() {
        guard countdownLeft <= 0 else { return }
        
        for subview in self.view.subviews {
            if subview is BubbleView {
                // floats bubble up
                subview.center.y -= self.floatSpeed
                
                // remove bubble when it floats outside the view
                if subview.frame.maxY < 0 {
                    subview.removeFromSuperview()
                }
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
    
    /// Method to remove a bubble from the view
    func removeBubble(_ bubble: BubbleView) {
        if let bubbleInView = self.view.viewWithTag(bubble.tag) {
            
            // animate fading bubble
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn,
                           animations: {
                            bubbleInView.alpha = 0.02
            }) { (_) in
                bubbleInView.removeFromSuperview()
            }
        }
    }
    
    /// Method to remove all bubbles in view
    func removeAllBubbles() {
        for subview in self.view.subviews {
            if subview is BubbleView {
                subview.removeFromSuperview()
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
            newBubble.tag = uniqueTag();
            
            self.view.addSubview(newBubble)
            self.view.sendSubview(toBack: newBubble)
            
            // animate growing bubble
            newBubble.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.1, animations: {
                newBubble.transform = CGAffineTransform.identity
            })
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
                newBubble.image = UIImage(named: "bubble-red.png")
            case pink:
                newBubble.image = UIImage(named: "bubble-pink.png")
            case UIColor.green:
                newBubble.image = UIImage(named: "bubble-green.png")
            case customBlue:
                newBubble.image = UIImage(named: "bubble-blue.png")
            case UIColor.black:
                newBubble.image = UIImage(named: "bubble-black.png")
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
    
    /// Function to get a unique tag
    func uniqueTag() -> Int {
        // loop until a valid tag is available between range 1 to 50
        while true {
            let uniqueTag = randomSource.nextInt(upperBound: 50) + 1
            guard let _ = self.view.viewWithTag(uniqueTag) else {
                return uniqueTag
            }
        }
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
            pointView.center.y -= 50
            pointView.alpha = 0.02
        }) { (_) in
            pointView.removeFromSuperview()
        }

    }
    
    /// Touch lifecycle method for recognising popped bubble
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch?.location(in: self.view)
        
        for subview in self.view.subviews {
            if let poppedBubble = subview as? BubbleView {
                if (poppedBubble.layer.presentation()?.hitTest(touchLocation!)) != nil {
                    
                    playSound(title: "popSFX", extensionCode: "m4a")
                    
                    let points = pointsGained(from: poppedBubble.bubbleType!)
                    showPointView(for: poppedBubble, gainedPoints: points)
                    
                    self.score += points
                    
                    scoreLabel.text = String(self.score)
                    checkHighScore()
                    
                    // animate shrinking bubble
                    UIView.animate(withDuration: 0.1, animations: {
                        poppedBubble.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                    }) { (_) in
                        poppedBubble.removeFromSuperview()
                    }
                    
                }
            }

        }
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
        // keep original time and set the time of when to increase speed
        originalTime = timeLeft
        changeSpeedTime = originalTime
        
        countdownLabel.fade()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        
        bubbleTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateBubbleView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeAllBubbles()
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

