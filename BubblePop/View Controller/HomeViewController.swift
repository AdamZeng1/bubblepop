//
//  HomeViewController.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

extension UIButton {
    /// Shrinking animation
    func shrink() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (_) in
            
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        sender.shrink()
        
        if nameTextField.text == "" {
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.nameTextField.layer.borderColor = UIColor.red.cgColor
                self.nameTextField.layer.borderWidth = 1.0
                self.nameTextField.layer.cornerRadius = 5.0
                
                let rightTransform = CGAffineTransform(translationX: 10, y: 0)
                self.nameTextField.transform = rightTransform
                
            }) { (_) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    self.nameTextField.layer.borderColor = UIColor.lightGray.cgColor
                    self.nameTextField.layer.borderWidth = 0.25
                    
                    self.nameTextField.transform = CGAffineTransform.identity
                })
            }
        }
        else {
            performSegue(withIdentifier: "GameViewSegue", sender: nil)
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        sender.shrink()
        performSegue(withIdentifier: "SettingsViewSegue", sender: nil)
    }
    
    @IBAction func scoreboardButtonTapped(_ sender: UIButton) {
        sender.shrink()
        performSegue(withIdentifier: "ScoreViewSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewSegue" {
            let gameViewController = segue.destination as! GameViewController
            do {
                gameViewController.playerName = nameTextField.text
                gameViewController.gameSettings = try DataStorage().loadGameSettings()
            } catch {
                gameViewController.gameSettings = GameSettings()
            }
        }
    }
    
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
