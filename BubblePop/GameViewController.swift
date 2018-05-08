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

extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.magenta: return "magenta"
        default: return nil
        }
    }
}


class GameViewController: UIViewController {
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var countdownTimer: Timer?
    var gameTimer: Timer?
    
    var audioPlayerBGM: AVAudioPlayer?
    var audioPlayerSFX: AVAudioPlayer?
    
    var countdownLeft = 3
    
    var gameSettings: GameSettings?
    var playerName: String?
    
    var timeLeft = 60
    var maxBubbles = 15
    
    var score: Int = 0
    var highScore: Int = 0
    
    var bubbles: [BubbleType] = [BubbleType(color: .red, points: 1),
                                 BubbleType(color: .magenta, points: 2),
                                 BubbleType(color: .green, points: 5),
                                 BubbleType(color: .blue, points: 8),
                                 BubbleType(color: .black, points: 10)]
    
    let randomSource: GKRandomSource = GKARC4RandomSource()
    
    var previousBubble: BubbleType?
    var isComboPoint: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let settings = gameSettings {
            timeLeft = settings.gameTime
            maxBubbles = settings.maxBubbles
        }
        
        timerLabel.text = timeFormatted(timeLeft)

//        highScoreLabel.text = String(highScore)
        loadHighScore()
        showHighScore()
    }
    
    func loadHighScore() {
        do {
            var scoreboard = try DataStorage().loadScoreboard()
            scoreboard.sort(by: { $0.score > $1.score })
            highScore = scoreboard[0].score
        } catch {
            highScore = 0
        }
    }
    
    func showHighScore() {
        if score > highScore {
            highScore = score
            highScoreLabel.text = String(score)
        }
    }
    
    @objc func updateCountdown() {
        // Only counts down when the label is not hidden
        if !countdownLabel.isHidden {
            countdownLeft -= 1
        }
        
        // Stop countdown, hide the countdown label and play BGM sound when time is zero (game starts)
        if countdownLeft <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            countdownLabel.isHidden = true
            
            playSound(title: "popBGM", extensionCode: "mp3")
        }
        else {
            countdownLabel.text = String(countdownLeft)
            
            // Flash the countdown label
            countdownLabel.isHidden = !countdownLabel.isHidden
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
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
                }
                
//                timerLabel.text = String(timeLeft)
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
            case UIColor.magenta:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-magenta.png"), for: .normal)
            case UIColor.green:
                newBubble.setImage(UIImage.init(imageLiteralResourceName: "bubble-green.png"), for: .normal)
            case UIColor.blue:
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
    
    @objc func createBubble() {
        let randomX = CGFloat(randomSource.nextUniform()) * (self.view.frame.width-100)
        let randomY = CGFloat(randomSource.nextUniform()) * (self.view.frame.height-100)

        let newBubble = BubbleView(frame: CGRect(x: randomX, y: randomY, width: 80, height: 80))
        newBubble.bubbleType = randomBubbleType()
        setBubbleImage(of: newBubble)
        
        let validLocation = isValidLocation(of: newBubble)
        if validLocation {
            newBubble.addTarget(self, action: #selector(bubblePopped(_:)), for: .touchDown)
            self.view.addSubview(newBubble)
            self.view.sendSubview(toBack: newBubble)
        }
    }
    
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
    }
    
    @IBAction func bubblePopped(_ sender: BubbleView) {
        playSound(title: "popSFX", extensionCode: "m4a")
        
        let points = pointsGained(from: sender.bubbleType!)
        showPointView(for: sender, gainedPoints: points)
        
        self.score += points
        
        scoreLabel.text = String(self.score)
        showHighScore()
        
        /// for debugging
        let currentColor = sender.bubbleType!.color.name
        print("\(String(describing: currentColor!)) popped | +\(points) point | score = \(score)")
        
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

