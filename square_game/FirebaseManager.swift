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
                    print("🔐 Auth state changed: User logged in - \(user.uid)")
                    await self?.loadUserProfile(userId: user.uid)
                } else {
                    print("🔓 Auth state changed: User logged out")
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Register New User
    func registerUser(email: String, password: String, username: String, country: String) async throws {
        do {
            print("🔐 Starting user registration for email: \(email)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Firebase Auth user created with UID: \(result.user.uid)")
            
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
            
            print("💾 Saving user profile to Firestore...")
            try await saveUserProfile(profile)
            print("✅ User profile saved successfully")
            
            // Set the profile immediately
            userProfile = profile
            print("✅ User profile loaded: \(profile.username)")
            print("✅ Registration complete!")
            
            authError = nil
        } catch {
            print("❌ Registration error: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
            authError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            print("🔐 Signing in user: \(email)")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ User authenticated: \(result.user.uid)")
            
            await loadUserProfile(userId: result.user.uid)
            
            if userProfile == nil {
                print("⚠️ Profile not found, waiting and retrying...")
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                await loadUserProfile(userId: result.user.uid)
            }
            
            if let profile = userProfile {
                print("✅ Profile loaded: \(profile.username), Score: \(profile.totalScore)")
            } else {
                print("❌ Failed to load profile after retry")
            }
            
            authError = nil
        } catch {
            print("❌ Sign in error: \(error.localizedDescription)")
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
            print("📖 Loading user profile for: \(userId)")
            let document = try await db.collection("users").document(userId).getDocument()
            
            guard let data = document.data() else {
                print("❌ No user profile data found for userId: \(userId)")
                print("❌ Document exists: \(document.exists)")
                return
            }
            
            print("📄 Profile data found: \(data.keys)")
            
            // Manually parse the data
            userProfile = UserProfile(
                id: data["id"] as? String ?? userId,
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? "",
                country: data["country"] as? String ?? "",
                totalScore: data["totalScore"] as? Int ?? 0,
                gamesPlayed: data["gamesPlayed"] as? Int ?? 0,
                highestLevel: data["highestLevel"] as? Int ?? 1,
                achievements: data["achievements"] as? [String] ?? [],
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                lastPlayed: (data["lastPlayed"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            if let profile = userProfile {
                print("✅ Profile loaded successfully: \(profile.username)")
            }
        } catch {
            print("❌ Error loading user profile: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
        }
    }
    
    // MARK: - Refresh User Profile
    func refreshUserProfile() async {
        guard let userId = currentUser?.uid else {
            print("⚠️ Cannot refresh profile: no authenticated user")
            return
        }
        
        print("🔄 Refreshing user profile...")
        await loadUserProfile(userId: userId)
        
        if userProfile != nil {
            print("✅ Profile refresh successful")
        } else {
            print("❌ Profile refresh failed")
        }
    }
    
    // MARK: - Create Missing Profile
    func createMissingProfile() async {
        guard let user = currentUser else {
            print("⚠️ Cannot create profile: no authenticated user")
            return
        }
        
        print("🔧 Creating missing profile for user: \(user.uid)")
        
        // Try to get country from user metadata or use a default
        let defaultCountry = "Other" // Changed from "Unknown" to "Other" which is in the country list
        
        let profile = UserProfile(
            id: user.uid,
            username: user.email?.components(separatedBy: "@").first ?? "Player",
            email: user.email ?? "",
            country: defaultCountry,
            totalScore: 0,
            gamesPlayed: 0,
            highestLevel: 1,
            achievements: [],
            createdAt: Date(),
            lastPlayed: Date()
        )
        
        do {
            try await saveUserProfile(profile)
            userProfile = profile
            print("✅ Missing profile created successfully with country: \(defaultCountry)")
        } catch {
            print("❌ Failed to create profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update User Country
    func updateUserCountry(_ country: String) async {
        guard var profile = userProfile else {
            print("⚠️ Cannot update country: no profile loaded")
            return
        }
        
        profile.country = country
        
        do {
            try await saveUserProfile(profile)
            userProfile = profile
            print("✅ Country updated to: \(country)")
        } catch {
            print("❌ Failed to update country: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save User Profile
    private func saveUserProfile(_ profile: UserProfile) async throws {
        let data: [String: Any] = [
            "id": profile.id,
            "username": profile.username,
            "email": profile.email,
            "country": profile.country,
            "totalScore": profile.totalScore,
            "gamesPlayed": profile.gamesPlayed,
            "highestLevel": profile.highestLevel,
            "achievements": profile.achievements,
            "createdAt": Timestamp(date: profile.createdAt),
            "lastPlayed": Timestamp(date: profile.lastPlayed)
        ]
        
        try await db.collection("users").document(profile.id).setData(data)
    }
    
    // MARK: - Update User Stats
    func updateUserStats(score: Int, level: Int, mode: GameMode) async {
        guard let userId = currentUser?.uid, var profile = userProfile else {
            print("⚠️ Cannot update stats: userId=\(currentUser?.uid ?? "nil"), profile=\(userProfile == nil ? "nil" : "exists")")
            return
        }
        
        print("📊 Updating user stats: score=\(score), level=\(level), mode=\(mode)")
        profile.totalScore += score
        profile.gamesPlayed += 1
        profile.highestLevel = max(profile.highestLevel, level)
        profile.lastPlayed = Date()
        
        do {
            print("💾 Saving updated profile...")
            try await saveUserProfile(profile)
            userProfile = profile
            print("✅ Profile saved. Total score: \(profile.totalScore), Games: \(profile.gamesPlayed)")
            
            // Save score to leaderboard
            print("🏆 Saving score to leaderboard...")
            await saveScore(score: score, level: level, mode: mode)
            
            // Check and unlock achievements
            print("🎖️ Checking achievements...")
            await checkAchievements(score: score, level: level, mode: mode)
        } catch {
            print("❌ Error updating user stats: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
        }
    }
    
    // MARK: - Save Score to Leaderboard
    private func saveScore(score: Int, level: Int, mode: GameMode) async {
        guard let userId = currentUser?.uid,
              let profile = userProfile else {
            print("⚠️ Cannot save score: no user or profile")
            return
        }
        
        let scoreId = UUID().uuidString
        let scoreEntry: [String: Any] = [
            "id": scoreId,
            "userId": userId,
            "username": profile.username,
            "country": profile.country,
            "score": score,
            "level": level,
            "mode": mode.description,
            "timestamp": Timestamp(date: Date())
        ]
        
        do {
            print("💾 Saving score to Firestore: score=\(score), level=\(level), mode=\(mode.description)")
            try await db.collection("scores").document(scoreId).setData(scoreEntry)
            print("✅ Score saved to leaderboard successfully!")
        } catch {
            print("❌ Error saving score: \(error.localizedDescription)")
            print("❌ Score error details: \(error)")
        }
    }
    
    // MARK: - Fetch Global Leaderboard
    func fetchGlobalLeaderboard(limit: Int = 50) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> ScoreEntry? in
            let data = doc.data()
            guard let id = data["id"] as? String,
                  let userId = data["userId"] as? String,
                  let username = data["username"] as? String,
                  let country = data["country"] as? String,
                  let score = data["score"] as? Int,
                  let level = data["level"] as? Int,
                  let mode = data["mode"] as? String,
                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                return nil
            }
            return ScoreEntry(id: id, userId: userId, username: username, country: country, score: score, level: level, mode: mode, timestamp: timestamp)
        }
    }
    
    // MARK: - Fetch Regional Leaderboard
    func fetchRegionalLeaderboard(country: String, limit: Int = 50) async throws -> [ScoreEntry] {
        let snapshot = try await db.collection("scores")
            .whereField("country", isEqualTo: country)
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> ScoreEntry? in
            let data = doc.data()
            guard let id = data["id"] as? String,
                  let userId = data["userId"] as? String,
                  let username = data["username"] as? String,
                  let country = data["country"] as? String,
                  let score = data["score"] as? Int,
                  let level = data["level"] as? Int,
                  let mode = data["mode"] as? String,
                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                return nil
            }
            return ScoreEntry(id: id, userId: userId, username: username, country: country, score: score, level: level, mode: mode, timestamp: timestamp)
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
        
        return snapshot.documents.compactMap { doc -> ScoreEntry? in
            let data = doc.data()
            guard let id = data["id"] as? String,
                  let userId = data["userId"] as? String,
                  let username = data["username"] as? String,
                  let country = data["country"] as? String,
                  let score = data["score"] as? Int,
                  let level = data["level"] as? Int,
                  let mode = data["mode"] as? String,
                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                return nil
            }
            return ScoreEntry(id: id, userId: userId, username: username, country: country, score: score, level: level, mode: mode, timestamp: timestamp)
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
        guard var profile = userProfile else {
            print("⚠️ Cannot check achievements: no profile")
            return
        }
        
        print("🎖️ Checking achievements... Games: \(profile.gamesPlayed), Level: \(level), Total Score: \(profile.totalScore)")
        print("🎖️ Current achievements: \(profile.achievements)")
        
        var newAchievements: [String] = []
        
        // First Win
        if !profile.achievements.contains("first_win") && profile.gamesPlayed >= 1 {
            newAchievements.append("first_win")
            print("🎉 Unlocked: First Victory!")
        }
        
        // Level Master
        if !profile.achievements.contains("level_master") && level >= 10 {
            newAchievements.append("level_master")
            print("🎉 Unlocked: Level Master!")
        }
        
        // Score Hunter
        if !profile.achievements.contains("score_hunter") && profile.totalScore >= 10000 {
            newAchievements.append("score_hunter")
            print("🎉 Unlocked: Score Hunter!")
        }
        
        // Marathon Runner
        if !profile.achievements.contains("marathon_runner") && profile.gamesPlayed >= 50 {
            newAchievements.append("marathon_runner")
            print("🎉 Unlocked: Marathon Runner!")
        }
        
        if !newAchievements.isEmpty {
            print("✅ Found \(newAchievements.count) new achievement(s): \(newAchievements)")
            profile.achievements.append(contentsOf: newAchievements)
            do {
                try await saveUserProfile(profile)
                userProfile = profile
                print("✅ Achievements saved!")
            } catch {
                print("❌ Error updating achievements: \(error.localizedDescription)")
            }
        } else {
            print("ℹ️ No new achievements unlocked")
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
