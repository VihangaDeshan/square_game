//
//  GameViewModel.swift
//  square_game
//
//  Memory Match Game - Game Logic ViewModel
//

import SwiftUI

/// ViewModel that manages all game state and logic for the Memory Match game
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var cards: [Card] = []
    @Published var turns: Int = 0
    @Published var matchesFound: Int = 0
    @Published var size: Int = 4
    @Published var gameID = UUID()
    @Published var isBusy: Bool = false
    @Published var winMessage: String = ""
    
    // MARK: - Private Properties
    
    private var firstIndex: Int? = nil
    
    // MARK: - Constants
    
    private let colors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink,
        .yellow, .cyan, .mint, .indigo, .teal, .brown
    ]
    
    // MARK: - Computed Properties
    
    /// Calculates the current score based on matches and turns
    var score: Int {
        let minTurns = (size * size) / 2
        let penalty = max(0, (turns - minTurns) * 10)
        return (matchesFound * 20) - penalty
    }
    
    /// Calculates the minimum number of turns needed to win
    var minimumTurns: Int {
        (size * size) / 2
    }
    
    /// Checks if the game is active
    var isGameActive: Bool {
        !cards.isEmpty
    }
    
    // MARK: - Game Setup
    
    /// Sets up a new game with the specified grid size
    /// - Parameter newSize: The size of the grid (e.g., 3 for 3x3, 5 for 5x5)
    func setupGame(_ newSize: Int) {
        size = newSize
        turns = 0
        matchesFound = 0
        firstIndex = nil
        winMessage = ""
        
        let total = size * size
        let pairCount = total / 2
        var newCards: [Card] = []
        
        // Create pairs of cards
        for i in 0..<pairCount {
            newCards.append(Card(colorIndex: i))
            newCards.append(Card(colorIndex: i))
        }
        newCards.shuffle()
        
        // Handle the middle square for odd grids (3x3, 5x5, 7x7)
        if total % 2 != 0 {
            let bonusCard = Card(
                colorIndex: -1,
                isFlipped: true,
                isMatched: true,
                isBonus: true
            )
            newCards.insert(bonusCard, at: total / 2)
        }
        
        cards = newCards
        gameID = UUID() // Refresh the view identity
    }
    
    /// Resets the game and returns to the menu
    func exitToMenu() {
        cards = []
        turns = 0
        matchesFound = 0
        firstIndex = nil
        winMessage = ""
    }
    
    // MARK: - Game Logic
    
    /// Handles a tap on a card at the specified index
    /// - Parameter index: The index of the tapped card
    func handleTap(at index: Int) {
        guard !isBusy,
              index < cards.count,
              !cards[index].isFlipped,
              !cards[index].isMatched else {
            return
        }
        
        withAnimation {
            cards[index].isFlipped = true
        }
        
        if let second = firstIndex {
            turns += 1
            checkForMatch(idx1: second, idx2: index)
        } else {
            firstIndex = index
        }
    }
    
    /// Checks if two cards match
    /// - Parameters:
    ///   - idx1: Index of the first card
    ///   - idx2: Index of the second card
    private func checkForMatch(idx1: Int, idx2: Int) {
        guard idx1 >= 0, idx2 >= 0,
              idx1 < cards.count,
              idx2 < cards.count else { return }
        
        if cards[idx1].colorIndex == cards[idx2].colorIndex {
            // Match found
            withAnimation {
                cards[idx1].isMatched = true
                cards[idx2].isMatched = true
            }
            matchesFound += 1
            firstIndex = nil
            checkWin()
        } else {
            // No match - flip cards back after a delay
            // Store card IDs to safely reference them after the delay
            let card1ID = cards[idx1].id
            let card2ID = cards[idx2].id
            isBusy = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                withAnimation {
                    // Find cards by ID to handle potential array modifications
                    if let idx1 = self.cards.firstIndex(where: { $0.id == card1ID }) {
                        self.cards[idx1].isFlipped = false
                    }
                    if let idx2 = self.cards.firstIndex(where: { $0.id == card2ID }) {
                        self.cards[idx2].isFlipped = false
                    }
                }
                self.firstIndex = nil
                self.isBusy = false
            }
        }
    }
    
    /// Checks if the player has won the game
    private func checkWin() {
        let totalPairs = (size * size) / 2
        if matchesFound == totalPairs {
            let minTurns = totalPairs
            if turns == minTurns {
                winMessage = "⭐ GREAT WIN! ⭐"
            } else {
                winMessage = "General Win"
            }
        }
    }
    
    /// Gets the color for a card at the specified index
    /// - Parameter card: The card to get the color for
    /// - Returns: The color for the card
    func getColor(for card: Card) -> Color {
        guard card.colorIndex != -1 else { return .clear }
        return colors[card.colorIndex % colors.count]
    }
}
