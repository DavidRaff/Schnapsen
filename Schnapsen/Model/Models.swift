//
//  Models.swift
//  Schnapsen
//
//  Created by David Laczkovits on 10.10.23.
//

import Foundation

class Player : ObservableObject {
    var points = 0
    var cards : [Card]
    var onTurn : Bool
    
    init(cards: [Card], onTurn: Bool) {
        self.cards = cards
        self.onTurn = onTurn
    }
}

let samplePlayer = Player(cards: [
    Card(card: "Herz-2"),
    Card(card: "Herz-3"),
    Card(card: "Herz-4"),
    Card(card: "Herz-10"),
    Card(card: "Herz-11")
], onTurn: true)

class Computer : ObservableObject {
    var points = 0
    var cards : [Card]
    var onTurn : Bool
    
    init(cards: [Card], onTurn: Bool) {
        self.cards = cards
        self.onTurn = onTurn
    }
}

let samplePc = Computer(cards: [
    Card(card: "Pik-2"),
    Card(card: "Pik-3"),
    Card(card: "Pik-4"),
    Card(card: "Pik-10"),
    Card(card: "Pik-11")
], onTurn: true)

class Card : Identifiable, ObservableObject {
    
    var id = UUID()
    var card : String
    
    init(card: String) {
        self.card = card
    }
}
