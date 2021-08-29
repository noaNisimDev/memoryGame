//
//  Utils.swift
//  NoaMemoryGame
//


import Foundation
import UIKit

class Utils{
    
    static var cardImages:[UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!,
        UIImage(named: "6")!,
        UIImage(named: "7")!,
        UIImage(named: "8")!
    ];
    
    static func getCardsArray() -> [Card] { // Generate shuffled cards array
        var cardsArray = [Card]()
        for i in 0...7 {
            let tempImage:UIImage = cardImages[i]
            let card = Card(image: tempImage)
            cardsArray.append(card)
            let card2 = card.copy()
            cardsArray.append(card2)
        }
        cardsArray.shuffle()
        return cardsArray
    }
    
    static func getScores() -> [Score] {
        if let data = UserDefaults.standard.data(forKey: "scores"){
            do {
                let decoder = JSONDecoder()
                let scores = try decoder.decode([Score].self, from: data)
                return scores
            } catch {
                print("Error")
            }
            
        }
        return []
    }
    
    static func saveScore(score: Score) {
        var scores = getScores()
        scores.append(score)
        var sorted = scores.sorted {
            $0.time < $1.time
        }
        if(sorted.count > 10){
            sorted.removeLast()
        }
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(sorted)
            UserDefaults.standard.set(data, forKey: "scores")
        } catch {
            print("Error")
        }
    }
}
