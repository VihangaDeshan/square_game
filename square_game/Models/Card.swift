//
//  Card.swift
//  square_game
//
//  Memory Match Game - Card Model
//

import Foundation

/// Represents a single card in the memory match game
struct Card: Identifiable {
    let id = UUID()
    let colorIndex: Int
    var isFlipped: Bool = false
    var isMatched: Bool = false
    var isBonus: Bool = false
}
