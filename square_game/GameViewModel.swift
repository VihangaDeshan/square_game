import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cards: [Card] = []
    @Published var gameState: GameState = .menu
    @Published var stats: GameStats = GameStats()
    @Published var levelConfig: LevelConfig = LevelConfig(level: 1)
    @Published var showNameInput: Bool = false
    @Published var shouldAdvanceAfterNameInput: Bool = false
    
    // MARK: - Private Properties
    private var firstSelectedIndex: Int? = nil
    private var isBusy: Bool = false
    private var timer: AnyCancellable?
    
    let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan, .mint, .indigo, .teal, .brown]
    
    var gridSize: Int {
        return levelConfig.gridSize
    }
    
    // MARK: - Game Setup
    func startNewGame(level: Int = 1, mode: GameMode? = nil) {
        stats.currentLevel = level
        levelConfig = LevelConfig(level: level, mode: mode)
        setupCards()
        stats.reset()
        
        if levelConfig.mode == .time || levelConfig.mode == .difficult {
            stats.timeRemaining = levelConfig.maxTime ?? 30
        }
        
        // Start peeking phase
        gameState = .peeking
        flipAllCards(true)
        
        // After 3 seconds, flip back and start game
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.flipAllCards(false)
            self?.gameState = .playing
            
            // Start timer if in time or difficult mode
            if self?.levelConfig.mode == .time || self?.levelConfig.mode == .difficult {
                self?.startTimer()
            }
        }
    }
    
    private func setupCards() {
        let totalCells = gridSize * gridSize
        let pairCount = totalCells / 2
        var newCards: [Card] = []
        
        // Create pairs
        for i in 0..<pairCount {
            newCards.append(Card(colorIndex: i % colors.count))
            newCards.append(Card(colorIndex: i % colors.count))
        }
        
        newCards.shuffle()
        
        // Insert bonus card in center for odd grids
        if totalCells % 2 != 0 {
            let bonusCard = Card(colorIndex: -1, isFlipped: true, isMatched: true, isBonus: true)
            newCards.insert(bonusCard, at: totalCells / 2)
        }
        
        cards = newCards
        firstSelectedIndex = nil
    }
    
    private func flipAllCards(_ flipped: Bool) {
        for i in 0..<cards.count {
            if !cards[i].isBonus {
                cards[i].isFlipped = flipped
            }
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.stats.timeRemaining > 0 {
                    self.stats.timeRemaining -= 1
                } else {
                    self.handleTimeOut()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Card Tap Handler
    func handleCardTap(at index: Int) {
        guard gameState == .playing,
              !isBusy,
              !cards[index].isFlipped,
              !cards[index].isMatched,
              !cards[index].isBonus else { return }
        
        withAnimation(.spring(response: 0.3)) {
            cards[index].isFlipped = true
        }
        
        if let firstIndex = firstSelectedIndex {
            // Second card selected
            stats.turns += 1
            checkForMatch(first: firstIndex, second: index)
        } else {
            // First card selected
            firstSelectedIndex = index
        }
    }
    
    private func checkForMatch(first: Int, second: Int) {
        if cards[first].colorIndex == cards[second].colorIndex {
            // Match found
            cards[first].isMatched = true
            cards[second].isMatched = true
            stats.matchesFound += 1
            firstSelectedIndex = nil
            
            // In difficult mode, shuffle remaining card colors after each match
            if levelConfig.mode == .difficult {
                shuffleRemainingColors()
            }
            
            checkWinCondition()
        } else {
            // No match - flip back after delay
            isBusy = true
            firstSelectedIndex = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                withAnimation(.spring(response: 0.3)) {
                    self.cards[first].isFlipped = false
                    self.cards[second].isFlipped = false
                }
                self.isBusy = false
                self.checkLossCondition()
            }
        }
    }
    
    // MARK: - Difficult Mode: Shuffle Remaining Colors
    private func shuffleRemainingColors() {
        stats.colorShuffles += 1
        
        // Get all unmatched, non-bonus cards
        var unmatchedIndices: [Int] = []
        for i in 0..<cards.count {
            if !cards[i].isMatched && !cards[i].isBonus {
                unmatchedIndices.append(i)
            }
        }
        
        // Extract their color indices
        var colorIndices = unmatchedIndices.map { cards[$0].colorIndex }
        
        // Shuffle the colors
        colorIndices.shuffle()
        
        // Reassign shuffled colors with animation
        withAnimation(.easeInOut(duration: 0.5)) {
            for (index, cardIndex) in unmatchedIndices.enumerated() {
                cards[cardIndex] = Card(
                    colorIndex: colorIndices[index],
                    isFlipped: cards[cardIndex].isFlipped,
                    isMatched: cards[cardIndex].isMatched,
                    isBonus: cards[cardIndex].isBonus
                )
            }
        }
    }
    
    // MARK: - Win/Loss Conditions
    private func checkWinCondition() {
        let totalPairs = (gridSize * gridSize) / 2
        if stats.matchesFound == totalPairs {
            stopTimer()
            
            // Check if player achieved perfect score (4 moves) and award bonus life
            if levelConfig.mode == .score && stats.turns == LevelConfig.perfectTurns {
                stats.bonusLives += 1 // Award bonus life for perfect game
            }
            
            calculateScore()
            gameState = .won
        }
    }
    
    private func checkLossCondition() {
        if levelConfig.mode == .score {
            // Check if player has exceeded max allowed turns
            if let maxTurns = levelConfig.maxTurns, stats.turns > maxTurns {
                // Exceeded max turns - level failed
                handleGameOver()
            }
        }
    }
    
    private func handleTimeOut() {
        stopTimer()
        handleGameOver()
    }
    
    private func handleGameOver() {
        if stats.bonusLives > 0 {
            // Use bonus life
            stats.bonusLives -= 1
            
            if levelConfig.mode == .score {
                // Grant 2 extra turns
                if let maxTurns = levelConfig.maxTurns {
                    levelConfig = LevelConfig(level: stats.currentLevel)
                    // Temporarily increase max turns
                    stats.turns = maxTurns - 2
                }
            } else {
                // Grant 10 extra seconds
                stats.timeRemaining = 10
                startTimer()
            }
        } else {
            stopTimer()
            calculateScore()
            gameState = .lost
        }
    }
    
    // MARK: - Scoring
    private func calculateScore() {
        let baseScore = stats.matchesFound * 100
        var bonus = 0
        
        if levelConfig.mode == .score {
            // Bonus for efficient turns
            if let maxTurns = levelConfig.maxTurns {
                let minTurns = (gridSize * gridSize) / 2
                let turnsUsed = stats.turns
                if turnsUsed == minTurns {
                    bonus += 200 // Perfect game
                } else if turnsUsed < maxTurns {
                    bonus += (maxTurns - turnsUsed) * 20
                }
            }
        } else {
            // Bonus for remaining time
            bonus += stats.timeRemaining * 10
        }
        
        // Level multiplier
        let levelBonus = stats.currentLevel * 50
        
        stats.totalScore = baseScore + bonus + levelBonus
    }
    
    // MARK: - Level Progression
    func advanceToNextLevel() {
        stats.currentLevel += 1
        stats.bonusLives = 1 // Reset bonus life for new level
        let currentMode = levelConfig.mode
        startNewGame(level: stats.currentLevel, mode: currentMode)
    }
    
    func restartCurrentLevel() {
        stats.bonusLives = 1
        let currentMode = levelConfig.mode
        startNewGame(level: stats.currentLevel, mode: currentMode)
    }
    
    func returnToMenu() {
        stopTimer()
        gameState = .menu
        stats = GameStats()
        cards = []
    }
    
    // MARK: - Mode Selection
    func startInMode(_ mode: GameMode) {
        switch mode {
        case .score:
            startNewGame(level: 1, mode: .score)
        case .time:
            startNewGame(level: 1, mode: .time)
        case .difficult:
            startNewGame(level: 1, mode: .difficult)
        }
    }
}
