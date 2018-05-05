//
//  ViewController.swift
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


class ViewController: UIViewController {

    @IBOutlet weak var redBubble: UIButton!
    @IBOutlet weak var debugLabel: UILabel!

    var myTimer: Timer?
    var playerBGM: AVAudioPlayer?
    var playerSFX: AVAudioPlayer?
    
    var score: Int = 0
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
        
        createBubble(at: CGPoint(x: 0.0, y: 0.0))
        playSound(title: "popBGM", extensionCode: "mp3")
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

        /// for debugging
        let currentColor = sender.bubbleType!.color.name
        if let existingText = debugLabel.text {
            debugLabel.text = "\(existingText) \n \(String(describing: currentColor)) popped | +\(points) point | score = \(score)"
            print(debugLabel.text!)
        }
        
        debugLabel.sizeToFit()
        
        sender.removeFromSuperview()
        
        
        /*
         sender is UIView?
        int points = pointsForBubble(bubble);
        
        self.score += points;
        self.scoreLabel.text = @(self.score).description;
        
        [bubble removeFromSuperview];
         */
    }
    
    /// Method to play background music and bubble popped SFX
    func playSound(title: String, extensionCode: String) {
        guard let url = Bundle.main.url(forResource: title, withExtension: extensionCode) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
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
        myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(createBubble(at:)), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        myTimer?.invalidate()
        myTimer = nil
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        myTimer?.invalidate()
        myTimer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

