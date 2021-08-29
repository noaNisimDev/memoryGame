//
//  Card.swift
//  NoaMemoryGame
//

import UIKit

class Card {
    
    var id: String
    var visible: Bool = false
    var animalImg: UIImage!
    
    static var allCards = [Card]()
    
    init(card: Card) {
        self.id = card.id
        self.visible = card.visible
        self.animalImg = card.animalImg
    }
    
    init(image: UIImage) {
        self.id = NSUUID().uuidString
        self.visible = false
        self.animalImg = image
    }
    
    func equals(_ card: Card) -> Bool {
        return (card.id == id)
    }
    
    func copy() -> Card {
        return Card(card: self)
    }
}

