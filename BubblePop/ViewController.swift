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
    var player: AVAudioPlayer?
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
        //
        
        createBubble(at: CGPoint(x: 0.0, y: 0.0))
   
    }

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
    
    //    @objc func createBubble(at: CGPoint) {
    //        let bubbleView = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    //        let bubbleImage = UIImage.init(imageLiteralResourceName: "bubble-1-red-40%.png")
    //        bubbleView.setImage(bubbleImage, for: UIControlState.normal)
    //        bubbleView.addTarget(self, action: #selector(bubblePopped(_:)), for: UIControlEvents.touchUpInside)
    //
    //        self.view.addSubview(bubbleView)
    //
    //    }

    
    @objc func createBubble(at: CGPoint) {
        let randomX = CGFloat(randomSource.nextUniform()) * (self.view.frame.width-100)
        let randomY = CGFloat(randomSource.nextUniform()) * (self.view.frame.height-100)
        let bubbleView = BubbleView(frame: CGRect(x: randomX, y: randomY, width: 100, height: 100))
        bubbleView.bubbleType = randomBubbleType()
        
        switch bubbleView.bubbleType?.color {
        case UIColor.red:
            bubbleView.setImage(UIImage.init(imageLiteralResourceName: "bubble-red.png"), for: .normal)
        case UIColor.magenta:
            bubbleView.setImage(UIImage.init(imageLiteralResourceName: "bubble-magenta.png"), for: .normal)
        case UIColor.green:
            bubbleView.setImage(UIImage.init(imageLiteralResourceName: "bubble-green.png"), for: .normal)
        case UIColor.blue:
            bubbleView.setImage(UIImage.init(imageLiteralResourceName: "bubble-blue.png"), for: .normal)
        case UIColor.black:
            bubbleView.setImage(UIImage.init(imageLiteralResourceName: "bubble-black.png"), for: .normal)
        default:
            break
        }
        
        bubbleView.addTarget(self, action: #selector(bubblePopped(_:)), for: .touchUpInside)
        self.view.addSubview(bubbleView)
    }
    
    @IBAction func bubblePopped(_ sender: BubbleView) {
        playSound()
        
        var pointsGained: Double = 0.0
        
        if let currentBubble = sender.bubbleType {
            if previousBubble?.color == currentBubble.color {
                pointsGained = 1.5 * Double(currentBubble.points)
                self.score += Int(round(pointsGained))
            }
            else {
                pointsGained = Double(currentBubble.points)
                self.score += currentBubble.points
                previousBubble = currentBubble
            }
        }
        
        /// for debugging
        let currentColor = sender.bubbleType!.color.name
        if let existingText = debugLabel.text {
            debugLabel.text = "\(existingText) \n \(String(describing: currentColor)) popped | +\(Int(round(pointsGained))) point | score = \(score)"
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
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "popSFX", withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

