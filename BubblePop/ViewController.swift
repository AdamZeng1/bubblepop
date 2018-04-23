//
//  ViewController.swift
//  BubblePop
//
//  Created by Audwin on 23/4/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var redBubble: UIButton!
    @IBOutlet weak var debugLabel: UILabel!

//    var audioPlayer = AVAudioPlayer()
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let poppingSound =  Bundle.main.path(forResource: "popSFX", ofType: "m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: poppingSound!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print(error)
        }
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
    
    @IBAction func redBubbleTapped(_ sender: UIButton) {
        playSound()
        debugLabel.text = "red bubble is tapped"
        debugLabel.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

