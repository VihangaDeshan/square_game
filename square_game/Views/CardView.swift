//
//  CardView.swift
//  square_game
//
//  Memory Match Game - Card View Component
//

import SwiftUI

/// View component that displays a single card in the game
struct CardView: View {
    let card: Card
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(card.isFlipped || card.isMatched ? color : Color.gray)
            
            if !card.isFlipped && !card.isMatched {
                Text("?")
                    .foregroundColor(.white)
                    .font(.title)
            } else if card.isBonus {
                Text("🌟")
                    .font(.largeTitle)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(card.isMatched && !card.isBonus ? 0.3 : 1)
    }
}
