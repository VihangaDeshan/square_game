import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var highScoreManager: HighScoreManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                gameHeader
                
                Spacer()
                
                // Game Grid
                gameGrid
                
                Spacer()
                
                // Controls
                if viewModel.gameState == .playing || viewModel.gameState == .peeking {
                    Button("Exit to Menu") {
                        viewModel.returnToMenu()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding()
            
            // Overlays
            if viewModel.gameState == .peeking {
                peekingOverlay
            }
            
            if viewModel.gameState == .won {
                winOverlay
            }
            
            if viewModel.gameState == .lost {
                loseOverlay
            }
            
            if viewModel.showNameInput {
                nameInputOverlay
            }
        }
    }
    
    // MARK: - Header
    var gameHeader: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(viewModel.stats.currentLevel)")
                        .font(.title2).bold()
                    HStack(spacing: 4) {
                        Text(viewModel.levelConfig.mode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if viewModel.levelConfig.mode == .difficult {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.gridSize)×\(viewModel.gridSize)")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .bold()
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Lives: \(String(repeating: "🌟", count: viewModel.stats.bonusLives))")
                        .font(.headline)
                    let totalPairs = (viewModel.gridSize * viewModel.gridSize) / 2
                    Text("Matches: \(viewModel.stats.matchesFound)/\(totalPairs)")
                        .font(.caption)
                }
            }
            
            Divider()
            
            HStack {
                if viewModel.levelConfig.mode == .score {
                    VStack {
                        Text("Turns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.stats.turns)/\(viewModel.levelConfig.maxTurns ?? 0)")
                            .font(.title3).bold()
                            .foregroundColor(turnsColor)
                    }
                } else {
                    VStack {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.stats.timeRemaining)s")
                            .font(.title3).bold()
                            .foregroundColor(timeColor)
                    }
                }
                
                Spacer()
                
                if viewModel.levelConfig.mode == .difficult {
                    VStack {
                        Text("Shuffles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.stats.colorShuffles)")
                            .font(.title3).bold()
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.stats.totalScore)")
                        .font(.title3).bold()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
        )
    }
    
    var turnsColor: Color {
        guard let maxTurns = viewModel.levelConfig.maxTurns else { return .primary }
        let remaining = maxTurns - viewModel.stats.turns
        if remaining <= 1 { return .red }
        if remaining <= 2 { return .orange }
        return .green
    }
    
    var timeColor: Color {
        if viewModel.stats.timeRemaining <= 5 { return .red }
        if viewModel.stats.timeRemaining <= 10 { return .orange }
        return .green
    }
    
    // MARK: - Game Grid
    var gameGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.gridSize)
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                CardFlipView(
                    card: card,
                    color: card.colorIndex == -1 ? .clear : viewModel.colors[card.colorIndex % viewModel.colors.count]
                )
                .onTapGesture {
                    viewModel.handleCardTap(at: index)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Overlays
    var peekingOverlay: some View {
        VStack(spacing: 20) {
            Text("👀 Memorize the colors!")
                .font(.title).bold()
            Text("Game starts in 3 seconds...")
                .font(.headline)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
        )
    }
    
    var winOverlay: some View {
        VStack(spacing: 20) {
            // Check if it was a perfect game
            if viewModel.levelConfig.mode == .score && viewModel.stats.turns == 4 {
                Text("⭐ PERFECT GAME! ⭐")
                    .font(.largeTitle).bold()
                    .foregroundColor(.yellow)
                Text("Bonus Life Earned!")
                    .font(.title3)
                    .foregroundColor(.orange)
            } else {
                Text("🎉 Level Complete! 🎉")
                    .font(.largeTitle).bold()
                    .foregroundColor(.green)
            }
            
            Text("Score: \(viewModel.stats.totalScore)")
                .font(.title2)
            
            Text("Matches: \(viewModel.stats.matchesFound)")
                .font(.headline)
            
            if viewModel.levelConfig.mode == .score {
                Text("Turns Used: \(viewModel.stats.turns)/\(viewModel.levelConfig.maxTurns ?? 0)")
                    .font(.headline)
                    .foregroundColor(viewModel.stats.turns == 4 ? .green : .primary)
            } else {
                Text("Time Remaining: \(viewModel.stats.timeRemaining)s")
                    .font(.headline)
            }
            
            Divider()
            
            // Auto-progress countdown
            VStack(spacing: 8) {
                Text("Next level in \(viewModel.autoProgressCountdown)s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(5 - viewModel.autoProgressCountdown), total: 5.0)
                    .progressViewStyle(.linear)
                    .tint(.blue)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Next Level Now") {
                    viewModel.saveScoreToFirebase()
                    viewModel.advanceToNextLevel()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Menu") {
                    viewModel.saveScoreToFirebase()
                    viewModel.returnToMenu()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
    }
    
    var loseOverlay: some View {
        VStack(spacing: 20) {
            Text("😢 Game Over")
                .font(.largeTitle).bold()
                .foregroundColor(.red)
            
            Text("Score: \(viewModel.stats.totalScore)")
                .font(.title2)
            
            if viewModel.levelConfig.mode == .score {
                VStack(spacing: 8) {
                    Text("Exceeded max turns!")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text("Max: \(viewModel.levelConfig.maxTurns ?? 0) | Used: \(viewModel.stats.turns)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Time's up!")
                    .font(.headline)
            }
            
            Divider()
            
            // Auto-progress countdown
            VStack(spacing: 8) {
                Text("Retry in \(viewModel.autoProgressCountdown)s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(5 - viewModel.autoProgressCountdown), total: 5.0)
                    .progressViewStyle(.linear)
                    .tint(.orange)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Retry Now") {
                    viewModel.saveScoreToFirebase()
                    viewModel.restartCurrentLevel()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Menu") {
                    viewModel.saveScoreToFirebase()
                    viewModel.returnToMenu()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
    }
    
    var nameInputOverlay: some View {
        NameInputView(
            currentScore: viewModel.stats.totalScore,
            currentLevel: viewModel.stats.currentLevel,
            highScoreManager: highScoreManager
        ) {
            viewModel.showNameInput = false
            if viewModel.shouldAdvanceAfterNameInput {
                viewModel.advanceToNextLevel()
            } else {
                viewModel.returnToMenu()
            }
        }
    }
}

// MARK: - Card Flip View
struct CardFlipView: View {
    let card: Card
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.gradient)
                .overlay(
                    Text("?")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )
                .opacity(card.isFlipped || card.isMatched ? 0 : 1)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(color.gradient)
                .overlay(
                    Group {
                        if card.isBonus {
                            Text("🌟")
                                .font(.system(size: 40))
                        }
                    }
                )
                .opacity(card.isFlipped || card.isMatched ? 1 : 0)
        }
        .aspectRatio(1, contentMode: .fit)
        .rotation3DEffect(
            .degrees(card.isFlipped || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(card.isMatched && !card.isBonus ? 0.5 : 1)
        .scaleEffect(card.isMatched && !card.isBonus ? 0.95 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: card.isFlipped)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: card.isMatched)
    }
}

// MARK: - Name Input View
struct NameInputView: View {
    let currentScore: Int
    let currentLevel: Int
    @ObservedObject var highScoreManager: HighScoreManager
    let onComplete: () -> Void
    
    @State private var playerName: String = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🏆 New High Score! 🏆")
                .font(.title).bold()
                .foregroundColor(.orange)
            
            Text("Score: \(currentScore)")
                .font(.title2)
            
            Text("Enter your name:")
                .font(.headline)
            
            TextField("Player Name", text: $playerName)
                .textFieldStyle(.roundedBorder)
                .focused($isNameFieldFocused)
                .onAppear {
                    playerName = highScoreManager.getLastPlayerName()
                    isNameFieldFocused = true
                }
            
            Button("Save") {
                let name = playerName.isEmpty ? "Player" : playerName
                highScoreManager.saveLastPlayerName(name)
                highScoreManager.saveHighScore(
                    HighScoreEntry(playerName: name, score: currentScore, level: currentLevel, date: Date())
                )
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .disabled(playerName.isEmpty)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
        .padding()
    }
}
