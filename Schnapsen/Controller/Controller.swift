//
//  Controller.swift
//  Schnapsen
//
//  Created by David Laczkovits on 10.10.23.
//

import Foundation

@MainActor
class Controller : ObservableObject {
    
    @Published var player : Player
    @Published var pc : Computer
    var allCards : [Card] = []
    var cardsLeft : [Card] = []
    @Published var atout : String = ""
    @Published var currentPcCard : Card = Card(card: "computercard")
    @Published var currentPlayerCard : Card = Card(card: "playercard")
    var currentPlayerIndex = 0
    var currentPcIndex = 0
    var gameOver = false
    @Published var call20disabled = true
    @Published var call40disabled = true
    @Published var disableCards = [false,false,false,false,false]
    
    init() {
        allCards = [
            Card(card: "Herz-2"),
            Card(card: "Herz-3"),
            Card(card: "Herz-4"),
            Card(card: "Herz-10"),
            Card(card: "Herz-11"),
            
            Card(card: "Kreuz-2"),
            Card(card: "Kreuz-3"),
            Card(card: "Kreuz-4"),
            Card(card: "Kreuz-10"),
            Card(card: "Kreuz-11"),
            
            Card(card: "Karo-2"),
            Card(card: "Karo-3"),
            Card(card: "Karo-4"),
            Card(card: "Karo-10"),
            Card(card: "Karo-11"),
            
            Card(card: "Pik-2"),
            Card(card: "Pik-3"),
            Card(card: "Pik-4"),
            Card(card: "Pik-10"),
            Card(card: "Pik-11")
        ]
        
        cardsLeft = allCards
        
        
        let tempPlayer = Player(cards: [Card(card: "back"),Card(card: "back"),Card(card: "back"),Card(card: "back"),Card(card: "back")], onTurn: true)
        
        player = tempPlayer
        pc = samplePc
        
    }
    
    func newGame() {
        enableAllCards()
        
        cardsLeft = allCards
        player.points = 0
        player.onTurn = true
        pc.points = 0
        pc.onTurn = false
        giveRandomCards(player: true, pc: false)
        giveRandomCards(player: false, pc: true)
        gameOver = false
        currentPcCard = Card(card: "computercard")
        currentPlayerCard = Card(card: "playercard")
        canCall20()
        canCall40()
    }
    
    func choosePcCard() -> Card {
        let pcCard = pc.cards.randomElement()!
        
        for i in 0..<pc.cards.count {
            if pcCard.card == pc.cards[i].card {
                currentPcIndex = i
            }
        }
        
        return pcCard
    }
    
    func chooseCard(card: Card) {
        disableAllCards()
        
        call20disabled = true
        call40disabled = true
        
        currentPlayerCard = card
        
        for i in 0..<5 {
            if currentPlayerCard.card == player.cards[i].card {
                currentPlayerIndex = i
            }
        }
        
        if currentPcCard.card == "computercard" {
            currentPcCard = choosePcCard()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.validateCards()
        }
    }
    
    func giveNewCard() {
        
        if !cardsLeft.isEmpty {
            let playerCard = cardsLeft.randomElement()!
            
            cardsLeft.removeAll { card in
                return card.card == playerCard.card
            }
            
            let pcCard = cardsLeft.randomElement()!
            
            cardsLeft.removeAll { card in
                return card.card == pcCard.card
            }
            
            player.cards[currentPlayerIndex] = playerCard
            pc.cards[currentPcIndex] = pcCard
        }
    }
    
    func validateCards() {
        
        let split = currentPlayerCard.card.split(separator: "-")
        let playerDek = split[0]
        let playerFace = Int(split[1])!
        
        let pcsplit = currentPcCard.card.split(separator: "-")
        let pcDek = pcsplit[0]
        let pcFace = Int(pcsplit[1])!
        
        var wasPlayerTurn = false
        
        if player.onTurn {
            wasPlayerTurn = true
        }
        
        let points = playerFace + pcFace
        
        if playerDek == atout && pcDek == atout {
            if playerFace > pcFace {
                player.points += points
                player.onTurn = true
                pc.onTurn = false
            } else {
                pc.points += points
                player.onTurn = false
                pc.onTurn = true
            }
        } else if playerDek == atout && pcDek != atout {
            player.points += points
            player.onTurn = true
            pc.onTurn = false
        } else if playerDek != atout && pcDek == atout {
            pc.points += points
            player.onTurn = false
            pc.onTurn = true
        } else {
            if wasPlayerTurn {
                if playerDek == pcDek {
                    if playerFace > pcFace {
                        player.points += points
                        player.onTurn = true
                        pc.onTurn = false
                    } else {
                        pc.points += points
                        player.onTurn = false
                        pc.onTurn = true
                    }
                } else {
                    player.points += points
                    player.onTurn = true
                    pc.onTurn = false
                }
            } else {
                if playerDek == pcDek {
                    if playerFace > pcFace {
                        player.points += points
                        player.onTurn = true
                        pc.onTurn = false
                    } else {
                        pc.points += points
                        player.onTurn = false
                        pc.onTurn = true
                    }
                } else {
                    pc.points += points
                    player.onTurn = false
                    pc.onTurn = true
                }
            }
        }
        
        enableAllCards()
        
        if player.points > 65 {
            atout = "Player wins"
            gameOver = true
            disableAllCards()
            call20disabled = true
            call40disabled = true
            
        } else if pc.points > 65 {
            atout = "PC wins"
            gameOver = true
            disableAllCards()
            call20disabled = true
            call40disabled = true
        }
        
        if !cardsLeft.isEmpty {
            giveNewCard()
        } else {
            pc.cards.remove(at: currentPcIndex)
            player.cards[currentPlayerIndex].card = "back"
            for i in 0..<5 {
                if player.cards[i].card == "back" {
                    disableCardAtIndex(i: i)
                }
            }
        }
        
        currentPcCard = Card(card: "computercard")
        currentPlayerCard = Card(card: "playercard")
        
        if pc.onTurn == true && gameOver == false {
            currentPcCard = choosePcCard()
        } else {
            canCall20()
            canCall40()
        }
        
    }
    
    func canCall20() {
        var isKingHerz = false
        var isQueenHerz = false
        var isKingKaro = false
        var isQueenKaro = false
        var isKingKreuz = false
        var isQueenKreuz = false
        var isKingPik = false
        var isQueenPik = false
        
        for i in 0..<5 {
            if player.cards[i].card != "back" {
                let split = player.cards[i].card.split(separator: "-")
                if split[0] == "Kreuz" && split[0] != atout {
                    if split[1] == "3" {
                        isQueenKreuz = true
                    } else if split[1] == "4" {
                        isKingKreuz = true
                    }
                } else if split[0] == "Karo"  && split[0] != atout {
                    if split[1] == "3" {
                        isQueenKaro = true
                    } else if split[1] == "4" {
                        isKingKaro = true
                    }
                } else if split[0] == "Pik"  && split[0] != atout {
                    if split[1] == "3" {
                        isQueenPik = true
                    } else if split[1] == "4" {
                        isKingPik = true
                    }
                } else if split[0] == "Herz"  && split[0] != atout {
                    if split[1] == "3" {
                        isQueenHerz = true
                    } else if split[1] == "4" {
                        isKingHerz = true
                    }
                }
            }
        }
        
        if isKingPik && isQueenPik {
            call20disabled = false
        } else if isKingHerz && isQueenHerz {
            call20disabled = false
        } else if isKingKaro && isQueenKaro {
            call20disabled = false
        } else if isKingKreuz && isQueenKreuz {
            call20disabled = false
        }
    }
    
    func canCall40() {
        var isQueen = false
        var isKing = false
        
        for i in 0..<5 {
            if player.cards[i].card != "back" {
                let split = player.cards[i].card.split(separator: "-")
                if split[0] == atout {
                    if split[1] == "3" {
                        isQueen = true
                    } else if split[1] == "4" {
                        isKing = true
                    }
                }
            }
        }
        
        if isQueen && isKing {
            call40disabled = false
        }
    }
    
    func call20() {
        player.points += 20
        call20disabled = true
        
        var indexKingHerz = -1
        var indexQueenHerz = -1
        var indexKingKaro = -1
        var indexQueenKaro = -1
        var indexKingKreuz = -1
        var indexQueenKreuz = -1
        var indexKingPik = -1
        var indexQueenPik = -1
        
        for i in 0..<5 {
            if player.cards[i].card != "back" {
                let split = player.cards[i].card.split(separator: "-")
                if split[0] == "Kreuz" && split[0] != atout {
                    if split[1] == "3" {
                        indexQueenKreuz = i
                    } else if split[1] == "4" {
                        indexKingKreuz = i
                    }
                } else if split[0] == "Karo"  && split[0] != atout {
                    if split[1] == "3" {
                        indexQueenKaro = i
                    } else if split[1] == "4" {
                        indexKingKaro = i
                    }
                } else if split[0] == "Pik"  && split[0] != atout {
                    if split[1] == "3" {
                        indexQueenPik = i
                    } else if split[1] == "4" {
                        indexKingPik = i
                    }
                } else if split[0] == "Herz"  && split[0] != atout {
                    if split[1] == "3" {
                        indexQueenHerz = i
                    } else if split[1] == "4" {
                        indexKingHerz = i
                    }
                }
            }
        }
        
        disableAllCards()
        
        if indexQueenHerz > -1 && indexKingHerz > -1 {
            enableCardAtIndex(i: indexQueenHerz)
            enableCardAtIndex(i: indexKingHerz)
        }
        
        if indexQueenKaro > -1 && indexKingKaro > -1 {
            enableCardAtIndex(i: indexQueenKaro)
            enableCardAtIndex(i: indexKingKaro)
        }
        
        if indexQueenPik > -1 && indexKingPik > -1 {
            enableCardAtIndex(i: indexQueenPik)
            enableCardAtIndex(i: indexKingPik)
        }
        
        if indexQueenKreuz > -1 && indexKingKreuz > -1 {
            enableCardAtIndex(i: indexQueenKreuz)
            enableCardAtIndex(i: indexKingKreuz)
        }
    }
    
    func call40() {
        player.points += 40
        call40disabled = true
        
        var queenIndex = 0
        var kingIndex = 0
        
        for i in 0..<5 {
            if player.cards[i].card != "back" {
                let split = player.cards[i].card.split(separator: "-")
                if split[0] == atout {
                    if split[1] == "3" {
                        queenIndex = i
                    } else if split[1] == "4" {
                        kingIndex = i
                    }
                }
            }
        }
        
        for i in 0..<5 {
            if i == queenIndex || i == kingIndex {
                enableCardAtIndex(i: i)
            } else {
                disableCardAtIndex(i: i)
            }
        }
    }
    
    func giveRandomCards(player: Bool, pc: Bool) {
        
        var cards : [Card] = []
        
        var getCards = true
        var getCardsCounter = 0
        
        while(getCards) {
            let chosenCard = cardsLeft.randomElement()
            cards.append(chosenCard!)
            
            cardsLeft.removeAll { card in
                return card.card == chosenCard!.card
            }
            
            getCardsCounter+=1
            if getCardsCounter == 5 {
                getCards = false
            }
        }
        
        let temp = allCards.randomElement()!.card.split(separator: "-")
        atout = String(temp[0])
        
        if player {
            self.player.cards = cards
        } else {
            self.pc.cards = cards
        }
    }
    
    func enableAllCards() {
        for i in 0..<5 {
            disableCards[i] = false
        }
    }
    
    func disableAllCards() {
        for i in 0..<5 {
            disableCards[i] = true
        }
    }
    
    func disableCardAtIndex(i:Int) {
        disableCards[i] = true
    }
    
    func enableCardAtIndex(i:Int) {
        disableCards[i] = false
    }
}

