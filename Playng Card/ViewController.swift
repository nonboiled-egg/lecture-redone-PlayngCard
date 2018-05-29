//
//  ViewController.swift
//  Playng Card
//
//  Created by Manuarii Ken Tekau Dauphin on 5/28/18.
//  Copyright © 2018 Junya Murakami. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...10{
            if let card = deck.draw(){
                print("\(card)")
            }
        }
        
    }

    


}

