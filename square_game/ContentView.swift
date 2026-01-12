//
//  ContentView.swift
//  square_game
//
//  Memory Match Game - Main View
//

import SwiftUI

/// Main view for the Memory Match game
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack {
            gameHeader
            
            if viewModel.isGameActive {
                gameGridView
                    .id(viewModel.gameID)
                
                if !viewModel.winMessage.isEmpty {
                    winOverlay
                }
                
                exitButton
            } else {
                menuView
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Main menu view for selecting difficulty
    private var menuView: some View {
        VStack(spacing: 20) {
            Text("Memory Match")
                .font(.largeTitle)
                .bold()
            
            Button("Easy (3x3)") {
                viewModel.setupGame(3)
            }
            
            Button("Medium (5x5)") {
                viewModel.setupGame(5)
            }
            
            Button("Hard (7x7)") {
                viewModel.setupGame(7)
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    /// Header showing game statistics
    private var gameHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Turns: \(viewModel.turns)")
                    .font(.headline)
                Text("Min Turns Needed: \(viewModel.minimumTurns)")
                    .font(.caption)
            }
            
            Spacer()
            
            Text("Score: \(viewModel.score)")
                .font(.title2)
                .bold()
        }
        .padding()
    }
    
    /// Grid view displaying all cards
    private var gameGridView: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: viewModel.size)
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.cards) { card in
                CardView(
                    card: card,
                    color: viewModel.getColor(for: card)
                )
                .onTapGesture {
                    if let idx = viewModel.cards.firstIndex(where: { $0.id == card.id }) {
                        viewModel.handleTap(at: idx)
                    }
                }
            }
        }
        .padding()
    }
    
    /// Overlay shown when the player wins
    private var winOverlay: some View {
        VStack {
            Text(viewModel.winMessage)
                .font(.largeTitle)
                .bold()
                .foregroundColor(viewModel.winMessage.contains("GREAT") ? .green : .blue)
            
            Text("Final Score: \(viewModel.score)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
        )
    }
    
    /// Button to exit to the main menu
    private var exitButton: some View {
        Button("Exit to Menu") {
            viewModel.exitToMenu()
        }
        .padding()
        .foregroundColor(.red)
    }
}
