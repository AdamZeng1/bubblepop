//
//  ViewController.swift
//  BubblePop
//
//  Created by Audwin on 23/4/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit // for random number generator

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //to generate a random number between 0 and the playfield width (or height), then assign that number to the view's center or frame
        //arc4random_uniform()
        //
        
        createBubble(at: CGPoint(x: 0.0, y: 0.0))
   
    }
    
    /*
    func randomBubbleType() -> UIColor {
        var bag: [UIColor] = []
        for _ in 1...40 {
            bag.append(.red)
        }
        for _ in 1...30 {
            bag.append(.magenta)
        }
        for _ in 1...15 {
            bag.append(.green)
        }
        for _ in 1...10 {
            bag.append(.blue)
        }
        for _ in 1...5 {
            bag.append(.black)
        }
        
        let choice: Int = randomSource.nextInt(upperBound: bag.count)
        return bag[choice]
    }
    */
    
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
        
        
//        let dice2 : Int = Int(arc4random_uniform(3) + 1)
//
//        bubbleView.bubbleType = bubbles[dice2]
        
        /*
        let button = UIButton()
        let randomX = CGFloat(randomSource.nextUniform()) * (self.view.frame.width-100)
        let randomY = CGFloat(randomSource.nextUniform()) * (self.view.frame.height-100)
        button.frame = CGRect(x: randomX, y: randomY, width: 50, height: 50)
        //button.backgroundColor = UIColor.red
        button.setTitle("Name your Button ", for: .normal)

        let image1 = UIImage(named: "bubble-5-green-15%.png")!

        button.setImage(image1, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        */
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    
    @IBAction func bubblePopped(_ sender: BubbleView) {
        playSound()
        self.score += sender.bubbleType!.points
        
        debugLabel.text = "red bubble is popped, score is \(score)"
        debugLabel.sizeToFit()
        
        sender.removeFromSuperview()
        
//        print(redBubble.buttonType)
        
        /*
         sender is UIView?
        int points = pointsForBubble(bubble);
        
        self.score += points;
        self.scoreLabel.text = @(self.score).description;
        
        [bubble removeFromSuperview];
         */
    }
    

//    @IBAction func bubbleTapped(_ sender: BubbleView) {
//        self.score += sender.bubbleType!.points
//        sender.removeFromSuperview()
//    }

    
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

