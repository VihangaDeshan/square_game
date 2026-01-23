import Foundation
import SwiftUI
import Combine

// DEFINE THIS ONLY ONCE HERE
struct HighScoreEntry: Identifiable, Codable {
    var id = UUID()
    let playerName: String
    let score: Int
    let level: Int // Added level to match your game logic
    let date: Date
}

class HighScoreManager: ObservableObject {
    @Published var highScores: [HighScoreEntry] = []
    
    private let highScoresKey = "highScores"
    private let lastPlayerNameKey = "lastPlayerName"
    
    init() {
        loadHighScores()
    }
    
    func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: highScoresKey),
           let decoded = try? JSONDecoder().decode([HighScoreEntry].self, from: data) {
            highScores = decoded.sorted { $0.score > $1.score }
        }
    }
    
    // Updated to accept the Entry object directly to match your View's call
    func saveHighScore(_ entry: HighScoreEntry) {
        highScores.append(entry)
        highScores.sort { $0.score > $1.score }
        
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        saveToDisk()
        saveLastPlayerName(entry.playerName)
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }
    
    func getLastPlayerName() -> String {
        UserDefaults.standard.string(forKey: lastPlayerNameKey) ?? ""
    }
    
    func saveLastPlayerName(_ name: String) {
        UserDefaults.standard.set(name, forKey: lastPlayerNameKey)
    }
    
    func isHighScore(_ score: Int) -> Bool {
        if highScores.count < 10 { return true }
        return score > (highScores.last?.score ?? 0)
    }
    
    func clearAllScores() {
        highScores = []
        UserDefaults.standard.removeObject(forKey: highScoresKey)
    }
}
