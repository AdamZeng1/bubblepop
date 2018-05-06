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

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var gameTimer: Timer?
    var playerBGM: AVAudioPlayer?
    var playerSFX: AVAudioPlayer?
    
    var gameTime = 15
    
    var score: Int = 0
    var highScore: Int = 20
    
    var bubbles: [BubbleType] = [BubbleType(color: .red, points: 1),
                                 BubbleType(color: .magenta, points: 2),
                                 BubbleType(color: .green, points: 5),
                                 BubbleType(color: .blue, points: 8),
                                 BubbleType(color: .black, points: 10)]
    
    let randomSource: GKRandomSource = GKARC4RandomSource()
    
    var previousBubble: BubbleType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //to generate a random number between 0 and the playfield width (or height), then assign that number to the view's center or frame
        //arc4random_uniform()
        
        highScoreLabel.text = String(highScore)
        
        
        showHighScore()
        timerLabel.text = String(gameTime)
        
//        createBubble(at: CGPoint(x: 0.0, y: 0.0))
        
        // Royalty free BGM credit: "Funny Plays" by SnowMusicStudio
        // Link: https://www.melodyloops.com/tracks/funny-plays/
        playSound(title: "popBGM", extensionCode: "mp3")
    }
    
    func showHighScore() {
        if score > Int(highScoreLabel.text!)! {
            highScoreLabel.text = String(score)
        }
    }
    
    @objc func updateView() {
        if gameTime > 0 {
            gameTime -= 1
            timerLabel.text = String(gameTime)
            
            createBubble(at: CGPoint(x: 0.0, y: 0.0))
        }
        else if gameTime == 0 {
            gameTimer?.invalidate()
            gameTimer = nil
            
            playerBGM?.stop()
            
            self.performSegue(withIdentifier: "ScoreBoardSegue", sender: self)
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
        switch newBubble.bubbleType?.color {
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
    
    @objc func createBubble(at: CGPoint) {
        let randomX = CGFloat(randomSource.nextUniform()) * (self.view.frame.width-100)
        let randomY = CGFloat(randomSource.nextUniform()) * (self.view.frame.height-100)
        
        let newBubble = BubbleView(frame: CGRect(x: randomX, y: randomY, width: 80, height: 80))
        newBubble.bubbleType = randomBubbleType()
        setBubbleImage(of: newBubble)
        
        let validLocation = isValidLocation(of: newBubble)
        if validLocation {
            newBubble.addTarget(self, action: #selector(bubblePopped(_:)), for: .touchUpInside)
            self.view.addSubview(newBubble)
        }
    }
    
    /// Function to calculate points earned
    /// If same colour bubbles are popped consecutively, bonus 1.5x the original point
    func pointsGained(from currentBubble: BubbleType) -> Int {
        if previousBubble?.color == currentBubble.color {
            let points = 1.5 * Double(currentBubble.points)
            return Int(round(points))
        }
        else {
            previousBubble = currentBubble
            return currentBubble.points
        }
    }
    
    @IBAction func bubblePopped(_ sender: BubbleView) {
        playSound(title: "popSFX", extensionCode: "m4a")

        let points = pointsGained(from: sender.bubbleType!)
        self.score += points
        
        scoreLabel.text = String(self.score)
        showHighScore()
        
        /// for debugging
        let currentColor = sender.bubbleType!.color.name
        print("\(String(describing: currentColor)) popped | +\(points) point | score = \(score)")
        
        sender.removeFromSuperview()
    }
    
    /// Method to play background music and bubble popped SFX
    func playSound(title: String, extensionCode: String) {
        guard let url = Bundle.main.url(forResource: title, withExtension: extensionCode) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if (title == "popBGM") {
                playerBGM = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                guard let playerBGM = playerBGM else { return }
                playerBGM.play()
            }
            else if (title == "popSFX") {
                playerSFX = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                guard let playerSFX = playerSFX else { return }
                playerSFX.play()
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateView), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScoreBoardSegue" {
            let scoreBoardViewController = segue.destination as! ScoreBoardViewController
            scoreBoardViewController.finalScore = score
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

