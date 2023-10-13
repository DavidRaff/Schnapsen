//
//  CardImageView.swift
//  Schnapsen
//
//  Created by David Laczkovits on 12.10.23.
//

import SwiftUI

struct CardImageView: View {
    
    @ObservedObject var viewController = Controller()
    @State var index : Int
    
    var body: some View {
        Button {
            withAnimation(.bouncy(duration: 1)) {
                viewController.currentPlayerCard = viewController.player.cards[index]
                viewController.chooseCard(card: viewController.player.cards[index])
            }
        } label: {
            Image(viewController.player.cards[index].card)
        }
        .disabled(viewController.disableCards[index])
    }
}

#Preview {
    CardImageView(index: 0)
}
