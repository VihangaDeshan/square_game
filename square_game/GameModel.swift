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
    case difficult
    
    var description: String {
        switch self {
        case .score: return "Score Mode"
        case .time: return "Time Mode"
        case .difficult: return "Difficult Mode"
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
    let gridSize: Int
    
    init(level: Int, mode: GameMode? = nil) {
        self.level = level
        
        // If mode is explicitly provided (for mode selection)
        if let explicitMode = mode {
            self.mode = explicitMode
            switch explicitMode {
            case .score:
                self.maxTime = nil
                self.gridSize = 3
                self.maxTurns = 11 - level
            case .time:
                self.maxTurns = nil
                self.maxTime = 30
                self.gridSize = 3
            case .difficult:
                self.maxTime = 45 // More time for larger grids
                self.maxTurns = nil
                // Grid size expands with levels
                // Levels 1-3: 3x3, 4-6: 4x4, 7-9: 5x5, 10+: 6x6
                if level <= 3 {
                    self.gridSize = 3
                } else if level <= 6 {
                    self.gridSize = 4
                } else if level <= 9 {
                    self.gridSize = 5
                } else {
                    self.gridSize = 6
                }
            }
        } else {
            // Default progression (Score -> Time)
            if level <= 7 {
                self.mode = .score
                self.maxTime = nil
                self.gridSize = 3
                self.maxTurns = 11 - level
            } else {
                self.mode = .time
                self.maxTurns = nil
                self.maxTime = 30
                self.gridSize = 3
            }
        }
    }
    
    // Check if this is the last score mode level
    var isLastScoreLevel: Bool {
        return level == 7 && mode == .score
    }
    
    // Minimum possible turns based on grid size
    var perfectTurns: Int {
        let totalCells = gridSize * gridSize
        let pairs = totalCells / 2
        return pairs
    }
    
    // Legacy perfect turns for 3x3 grid
    static let perfectTurns = 4
}

// MARK: - Game Stats
struct GameStats {
    var turns: Int = 0
    var matchesFound: Int = 0
    var timeRemaining: Int = 0
    var bonusLives: Int = 1
    var currentLevel: Int = 1
    var totalScore: Int = 0
    var colorShuffles: Int = 0 // Track how many times colors shuffled in difficult mode
    
    mutating func reset() {
        turns = 0
        matchesFound = 0
        timeRemaining = 0
        colorShuffles = 0
    }
}
