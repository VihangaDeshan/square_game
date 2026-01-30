import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - User Profile Model
struct UserProfile: Codable, Identifiable {
    var id: String
    var username: String
    var email: String
    var country: String
    var totalScore: Int
    var gamesPlayed: Int
    var highestLevel: Int
    var achievements: [String]
    var createdAt: Date
    var lastPlayed: Date
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, country, totalScore, gamesPlayed, highestLevel, achievements, createdAt, lastPlayed
    }
}

// MARK: - Score Entry Model
struct ScoreEntry: Codable, Identifiable {
    var id: String
    var userId: String
    var username: String
    var country: String
    var score: Int
    var level: Int
    var mode: String
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId, username, country, score, level, mode, timestamp
    }
}

// MARK: - Achievement Model
struct Achievement: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var requirement: Int
    var type: AchievementType
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, icon, requirement, type, isUnlocked, unlockedAt
    }
}

enum AchievementType: String, Codable {
    case firstWin = "first_win"
    case perfectGame = "perfect_game"
    case speedster = "speedster"
    case marathonRunner = "marathon_runner"
    case levelMaster = "level_master"
    case scoreHunter = "score_hunter"
    case matchMaker = "match_maker"
    case survivor = "survivor"
    case difficultChampion = "difficult_champion"
    case timeWizard = "time_wizard"
}

// MARK: - Firebase Authentication Manager
@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var authError: String?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Authentication Status
    func checkAuthStatus() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                } else {
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Register New User
    func registerUser(email: String, password: String, username: String, country: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user profile
            let profile = UserProfile(
                id: result.user.uid,
                username: username,
                email: email,
                country: country,
                totalScore: 0,
                gamesPlayed: 0,
                highestLevel: 1,
                achievements: [],
                createdAt: Date(),
                lastPlayed: Date()
            )
            
            try await saveUserProfile(profile)
            await loadUserProfile(userId: result.user.uid)
            
            authError = nil
        } catch {
            authError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await loadUserProfile(userId: result.user.uid)
            authError = nil
        } catch {
            authError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        userProfile = nil
        isAuthenticated = false
    }
    
    // MARK: - Load User Profile
    private func loadUserProfile(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if let data = document.data() {
                let decoder = Firestore.Decoder()
                userProfile = try decoder.decode(UserProfile.self, from: data)
            }
        } catch {
            print("Error loading user profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save User Profile
    private func saveUserProfile(_ profile: UserProfile) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(profile)
        try await db.collection("users").document(profile.id).setData(data)
    }
    
    // MARK: - Update User Stats
    func updateUserStats(score: Int, level: Int, mode: GameMode) async {
        guard let userId = currentUser?.uid, var profile = userProfile else { return }
        
        profile.totalScore += score
        profile.gamesPlayed += 1
        profile.highestLevel = max(profile.highestLevel, level)
        profile.lastPlayed = Date()
        
        do {
            try await saveUserProfile(profile)
            userProfile = profile
            
            // Save score to leaderboard
            await saveScore(score: score, level: level, mode: mode)
            
            // Check and unlock achievements
            await checkAchievements(score: score, level: level, mode: mode)
        } catch {
            print("Error updating user stats: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Score to Leaderboard
    private func saveScore(score: Int, level: Int, mode: GameMode) async {
        guard let userId = currentUser?.uid,
              let profile = userProfile else { return }
        
        let scoreEntry = ScoreEntry(
            id: UUID().uuidString,
            userId: userId,
            username: profile.username,
            country: profile.country,
            score: score,
            level: level,
            mode: mode.description,
            timestamp: Date()
        )
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(scoreEntry)
            try await db.collection("scores").document(scoreEntry.id).setData(data)
        } catch {
            print("Error saving score: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Global Leaderboard
    func fetchGlobalLeaderboard(limit: Int = 50) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        let decoder = Firestore.Decoder()
        return try snapshot.documents.compactMap { doc in
            try decoder.decode(ScoreEntry.self, from: doc.data())
        }
    }
    
    // MARK: - Fetch Regional Leaderboard
    func fetchRegionalLeaderboard(country: String, limit: Int = 50) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .whereField("country", isEqualTo: country)
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        let decoder = Firestore.Decoder()
        return try snapshot.documents.compactMap { doc in
            try decoder.decode(ScoreEntry.self, from: doc.data())
        }
    }
    
    // MARK: - Fetch User Score History
    func fetchUserScoreHistory() async throws -> [ScoreEntry] {
        guard let userId = currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("scores")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 100)
            .getDocuments()
        
        let decoder = Firestore.Decoder()
        return try snapshot.documents.compactMap { doc in
            try decoder.decode(ScoreEntry.self, from: doc.data())
        }
    }
    
    // MARK: - Achievements System
    func getDefaultAchievements() -> [Achievement] {
        return [
            Achievement(id: "first_win", title: "First Victory", description: "Complete your first level", icon: "star.fill", requirement: 1, type: .firstWin, isUnlocked: false),
            Achievement(id: "perfect_game", title: "Perfect Memory", description: "Complete a level with perfect score (4 turns)", icon: "crown.fill", requirement: 1, type: .perfectGame, isUnlocked: false),
            Achievement(id: "speedster", title: "Speedster", description: "Complete 5 time mode levels", icon: "bolt.fill", requirement: 5, type: .speedster, isUnlocked: false),
            Achievement(id: "marathon_runner", title: "Marathon Runner", description: "Play 50 games", icon: "figure.run", requirement: 50, type: .marathonRunner, isUnlocked: false),
            Achievement(id: "level_master", title: "Level Master", description: "Reach level 10", icon: "flag.checkered", requirement: 10, type: .levelMaster, isUnlocked: false),
            Achievement(id: "score_hunter", title: "Score Hunter", description: "Accumulate 10,000 total points", icon: "target", requirement: 10000, type: .scoreHunter, isUnlocked: false),
            Achievement(id: "match_maker", title: "Match Maker", description: "Find 500 matches", icon: "heart.fill", requirement: 500, type: .matchMaker, isUnlocked: false),
            Achievement(id: "survivor", title: "Survivor", description: "Use all bonus lives in a single game", icon: "shield.fill", requirement: 1, type: .survivor, isUnlocked: false),
            Achievement(id: "difficult_champion", title: "Difficult Champion", description: "Complete 10 difficult mode levels", icon: "flame.fill", requirement: 10, type: .difficultChampion, isUnlocked: false),
            Achievement(id: "time_wizard", title: "Time Wizard", description: "Finish with 20+ seconds remaining", icon: "clock.fill", requirement: 1, type: .timeWizard, isUnlocked: false)
        ]
    }
    
    private func checkAchievements(score: Int, level: Int, mode: GameMode) async {
        guard var profile = userProfile else { return }
        
        var newAchievements: [String] = []
        
        // First Win
        if !profile.achievements.contains("first_win") && profile.gamesPlayed >= 1 {
            newAchievements.append("first_win")
        }
        
        // Level Master
        if !profile.achievements.contains("level_master") && level >= 10 {
            newAchievements.append("level_master")
        }
        
        // Score Hunter
        if !profile.achievements.contains("score_hunter") && profile.totalScore >= 10000 {
            newAchievements.append("score_hunter")
        }
        
        // Marathon Runner
        if !profile.achievements.contains("marathon_runner") && profile.gamesPlayed >= 50 {
            newAchievements.append("marathon_runner")
        }
        
        if !newAchievements.isEmpty {
            profile.achievements.append(contentsOf: newAchievements)
            do {
                try await saveUserProfile(profile)
                userProfile = profile
            } catch {
                print("Error updating achievements: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Unlock Achievement
    func unlockAchievement(_ achievementId: String) async {
        guard var profile = userProfile else { return }
        
        if !profile.achievements.contains(achievementId) {
            profile.achievements.append(achievementId)
            do {
                try await saveUserProfile(profile)
                userProfile = profile
            } catch {
                print("Error unlocking achievement: \(error.localizedDescription)")
            }
        }
    }
}
