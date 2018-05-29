//
//  PlayingCard.swift
//  Playng Card
//
//  Created by Manuarii Ken Tekau Dauphin on 5/28/18.
//  Copyright © 2018 Junya Murakami. All rights reserved.
//

import Foundation
struct PlayingCard : CustomStringConvertible{
    var description: String {return "\(suit)\(rank)"}
    
    var suit: Suit
    var rank: Rank
    
    enum Suit: String, CustomStringConvertible{
        var description: String{}
        
        case spades = "♠️"
        case hearts = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"
        
        static var all = [Suit.spades, .hearts, .clubs, .diamonds]
    }
    
    enum Rank: CustomStringConvertible{
        var description: String{}
        
        case ace
        case numeric(Int)
        case face(String)
        
        var order: Int {
            switch self {
            case .ace: return 1
            case . numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        static var all: [Rank]{
            var allRanks = [Rank.ace]
            for pips in 2 ... 10 {
                allRanks.append(Rank.numeric(pips))
            }
            allRanks += [.face("J"),.face("Q"),.face("K")]
            return allRanks
        }
        
    }
}
