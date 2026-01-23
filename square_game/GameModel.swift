import SwiftUI

// MARK: - Card Model
struct Card: Identifiable, Equatable {
    let id = UUID()
    let colorIndex: Int
    var isFlipped: Bool = false
    var isMatched: Bool = false
    var isBonus: Bool = false
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Game Mode
enum GameMode {
    case score
    case time
    
    var description: String {
        switch self {
        case .score: return "Score Mode"
        case .time: return "Time Mode"
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case peeking
    case playing
    case paused
    case won
    case lost
}

// MARK: - Level Configuration
struct LevelConfig {
    let level: Int
    let mode: GameMode
    let maxTurns: Int?
    let maxTime: Int?
    
    init(level: Int) {
        self.level = level
        
        // Levels 1-7: Score Mode with decreasing max moves
        // Level 1: 10, Level 2: 9, Level 3: 8, Level 4: 7, Level 5: 6, Level 6: 5, Level 7: 4
        if level <= 7 {
            self.mode = .score
            self.maxTime = nil
            // Formula: maxTurns = 11 - level (10, 9, 8, 7, 6, 5, 4)
            self.maxTurns = 11 - level
        } else {
            // Levels 8+: Time Mode (3x3 grid with time limit)
            self.mode = .time
            self.maxTurns = nil
            self.maxTime = 30
        }
    }
    
    // Check if this is the last score mode level
    var isLastScoreLevel: Bool {
        return level == 7 && mode == .score
    }
    
    // Minimum possible turns for 3x3 grid (4 pairs)
    static let perfectTurns = 4
}


// MARK: - High Score Entry
struct HighScoreEntry: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let score: Int
    let level: Int
    let date: Date
    
    init(playerName: String, score: Int, level: Int) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.level = level
        self.date = Date()
    }
}

// MARK: - Game Stats
struct GameStats {
    var turns: Int = 0
    var matchesFound: Int = 0
    var timeRemaining: Int = 0
    var bonusLives: Int = 1
    var currentLevel: Int = 1
    var totalScore: Int = 0
    
    mutating func reset() {
        turns = 0
        matchesFound = 0
        timeRemaining = 0
    }
}
