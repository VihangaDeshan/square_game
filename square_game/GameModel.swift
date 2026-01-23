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
        
        // Levels 1-5: Score Mode
        if level <= 5 {
            self.mode = .score
            self.maxTime = nil
            // Level 1: 10 turns, Level 2: 8, Level 3: 6, Level 4: 5, Level 5: 4
            switch level {
            case 1: self.maxTurns = 10
            case 2: self.maxTurns = 8
            case 3: self.maxTurns = 6
            case 4: self.maxTurns = 5
            default: self.maxTurns = 4
            }
        } else {
            // Levels 6+: Time Mode
            self.mode = .time
            self.maxTurns = nil
            self.maxTime = 30
        }
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
