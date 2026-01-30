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
    @Published var autoProgressCountdown: Int = 5
    @Published var newAchievements: [Achievement] = []
    @Published var showAchievementPopup: Bool = false
    
    // MARK: - Private Properties
    private var firstSelectedIndex: Int? = nil
    private var isBusy: Bool = false
    private var timer: AnyCancellable?
    private var autoProgressTimer: AnyCancellable?
    private var perfectGameAchieved: Bool = false
    private var usedBonusLife: Bool = false
    private var timeRemainingAtEnd: Int = 0
    
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
            
            // Track time remaining for achievements
            timeRemainingAtEnd = stats.timeRemaining
            
            // Check if player achieved perfect score (4 moves) and award bonus life
            if levelConfig.mode == .score && stats.turns == LevelConfig.perfectTurns {
                stats.bonusLives += 1 // Award bonus life for perfect game
                perfectGameAchieved = true
            }
            
            calculateScore()
            gameState = .won
            
            // Start auto-progress timer
            startAutoProgressTimer()
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
    
    private func handleGameOver() {
        stopTimer()
        calculateScore()
        gameState = .lost
        startAutoProgressTimer()
    }
    
    private func handleTimeOut() {
        stopTimer()
        
        // Check if player has a bonus life
        if stats.bonusLives > 0 && !usedBonusLife {
            stats.bonusLives -= 1
            usedBonusLife = true
            
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
            
            // Start auto-progress timer for retry
            startAutoProgressTimer()
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
    
    func advanceToNextLevel() {
        stopAutoProgressTimer()
        stats.currentLevel += 1
        stats.bonusLives = 1 // Reset bonus life for new level
        let currentMode = levelConfig.mode
        perfectGameAchieved = false
        usedBonusLife = false
        timeRemainingAtEnd = 0
        startNewGame(level: stats.currentLevel, mode: currentMode)
    }
    
    func restartCurrentLevel() {
        stopAutoProgressTimer()
        stats.bonusLives = 1
        let currentMode = levelConfig.mode
        perfectGameAchieved = false
        usedBonusLife = false
        timeRemainingAtEnd = 0
        startNewGame(level: stats.currentLevel, mode: currentMode)
    }
    
    func returnToMenu() {
        stopTimer()
        stopAutoProgressTimer()
        gameState = .menu
        stats = GameStats()
        cards = []
        perfectGameAchieved = false
        usedBonusLife = false
        timeRemainingAtEnd = 0
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
    
    // MARK: - Auto Progress Timer
    private func startAutoProgressTimer() {
        autoProgressCountdown = 5
        autoProgressTimer?.cancel()
        
        autoProgressTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.autoProgressCountdown > 0 {
                    self.autoProgressCountdown -= 1
                } else {
                    self.handleAutoProgress()
                }
            }
    }
    
    private func stopAutoProgressTimer() {
        autoProgressTimer?.cancel()
        autoProgressTimer = nil
        autoProgressCountdown = 5
    }
    
    private func handleAutoProgress() {
        stopAutoProgressTimer()
        
        if gameState == .won {
            // Check for achievements before advancing
            checkAndUnlockAchievements()
            advanceToNextLevel()
        } else if gameState == .lost {
            restartCurrentLevel()
        }
    }
    
    // MARK: - Achievement Tracking
    func checkAndUnlockAchievements() {
        var unlockedAchievements: [Achievement] = []
        
        // Perfect Game Achievement
        if perfectGameAchieved {
            let achievement = Achievement(
                id: "perfect_game",
                title: "Perfect Memory",
                description: "Complete a level with perfect score (4 turns)",
                icon: "crown.fill",
                requirement: 1,
                type: .perfectGame,
                isUnlocked: true,
                unlockedAt: Date()
            )
            unlockedAchievements.append(achievement)
        }
        
        // Time Wizard Achievement
        if timeRemainingAtEnd >= 20 && (levelConfig.mode == .time || levelConfig.mode == .difficult) {
            let achievement = Achievement(
                id: "time_wizard",
                title: "Time Wizard",
                description: "Finish with 20+ seconds remaining",
                icon: "clock.fill",
                requirement: 1,
                type: .timeWizard,
                isUnlocked: true,
                unlockedAt: Date()
            )
            unlockedAchievements.append(achievement)
        }
        
        // Survivor Achievement
        if usedBonusLife {
            let achievement = Achievement(
                id: "survivor",
                title: "Survivor",
                description: "Use a bonus life and win",
                icon: "shield.fill",
                requirement: 1,
                type: .survivor,
                isUnlocked: true,
                unlockedAt: Date()
            )
            unlockedAchievements.append(achievement)
        }
        
        if !unlockedAchievements.isEmpty {
            newAchievements = unlockedAchievements
            
            // Upload to Firebase
            Task {
                for achievement in unlockedAchievements {
                    await FirebaseManager.shared.unlockAchievement(achievement.id)
                }
            }
        }
    }
    
    // MARK: - Save Score
    func saveScore(to highScoreManager: HighScoreManager) {
        // CRITICAL: Capture values immediately before any async operations
        let finalScore = stats.totalScore
        let finalLevel = stats.currentLevel
        let gameMode = levelConfig.mode
        
        print("🎮 saveScore called: score=\(finalScore), level=\(finalLevel), mode=\(gameMode)")
        
        // Always save to local high scores first
        if finalScore > 0 {
            let playerName = FirebaseManager.shared.userProfile?.username ?? "Player"
            let entry = HighScoreEntry(
                playerName: playerName,
                score: finalScore,
                level: finalLevel,
                date: Date()
            )
            print("💾 Saving local high score: \(finalScore) for \(playerName)")
            highScoreManager.saveHighScore(entry)
            print("✅ Local score saved")
        }
        
        // Save to Firebase if authenticated - using captured values
        Task {
            // Check if user has profile, if not create one
            if FirebaseManager.shared.currentUser != nil && FirebaseManager.shared.userProfile == nil {
                print("⚠️ User authenticated but no profile - attempting to create...")
                await FirebaseManager.shared.createMissingProfile()
            }
            
            await FirebaseManager.shared.updateUserStats(
                score: finalScore,
                level: finalLevel,
                mode: gameMode
            )
        }
    }
    
    // MARK: - Save Score to Firebase (deprecated)
    func saveScoreToFirebase() {
        // CRITICAL: Capture values immediately before any async operations
        let finalScore = stats.totalScore
        let finalLevel = stats.currentLevel
        let gameMode = levelConfig.mode
        
        print("⚠️ saveScoreToFirebase is deprecated")
        print("🎮 saveScoreToFirebase called: score=\(finalScore), level=\(finalLevel), mode=\(gameMode)")
        
        // Save to Firebase if authenticated
        Task {
            // Check if user has profile, if not create one
            if FirebaseManager.shared.currentUser != nil && FirebaseManager.shared.userProfile == nil {
                print("⚠️ User authenticated but no profile - attempting to create...")
                await FirebaseManager.shared.createMissingProfile()
            }
            
            await FirebaseManager.shared.updateUserStats(
                score: finalScore,
                level: finalLevel,
                mode: gameMode
            )
        }
    }
}
