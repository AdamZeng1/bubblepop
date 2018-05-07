//
//  HomeViewController.swift
//  BubblePop
//
//  Created by Audwin on 6/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var nameTextField: UITextField!
    
    var gameSettings: GameSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }

    @IBAction func playButtonTapped(_ sender: Any) {
        if nameTextField.text == "" {
            
            UIView.animate(withDuration: 0.1, animations: {
                
                let rightTransform = CGAffineTransform(translationX: 10, y: 0)
                self.nameTextField.transform = rightTransform
                
            }) { (_) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.nameTextField.transform = CGAffineTransform.identity
                })
            }
        }
        else {
            performSegue(withIdentifier: "GameViewSegue", sender: nil)
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SettingsViewSegue", sender: nil)
//        navigationController?.popViewController(animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewSegue" {
            let gameViewController = segue.destination as! GameViewController
            gameViewController.playerName = nameTextField.text
            gameViewController.gameSettings = self.gameSettings
        }
    }
    
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
