import Foundation
import FirebaseCore
import FirebaseFirestore
import UIKit
import Combine

// Import Analytics through FirebaseCore
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

// MARK: - Analytics Consent
struct AnalyticsConsent: Codable {
    var hasAgreed: Bool = false
    var agreedDate: Date?
    
    // Granular permissions
    var allowGameplayTracking: Bool = false
    var allowPerformanceTracking: Bool = false
    var allowCrashReporting: Bool = false
    var allowUsageStatistics: Bool = false
    var allowPersonalization: Bool = false
    
    var allPermissionsGranted: Bool {
        return allowGameplayTracking && allowPerformanceTracking && 
               allowCrashReporting && allowUsageStatistics && allowPersonalization
    }
}

// MARK: - Analytics Manager
@MainActor
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var consent: AnalyticsConsent {
        didSet {
            saveConsent()
            updateFirebaseAnalytics()
        }
    }
    
    @Published var needsConsent: Bool = false
    
    private var sessionStartTime: Date?
    private var gameStartTime: Date?
    private var levelStartTime: Date?
    private var db = Firestore.firestore()
    
    private init() {
        self.consent = Self.loadConsent()
        self.needsConsent = !consent.hasAgreed
    }
    
    // MARK: - Consent Management
    private static func loadConsent() -> AnalyticsConsent {
        guard let data = UserDefaults.standard.data(forKey: "analyticsConsent"),
              let consent = try? JSONDecoder().decode(AnalyticsConsent.self, from: data) else {
            return AnalyticsConsent()
        }
        return consent
    }
    
    private func saveConsent() {
        if let data = try? JSONEncoder().encode(consent) {
            UserDefaults.standard.set(data, forKey: "analyticsConsent")
        }
    }
    
    func updateConsent(_ newConsent: AnalyticsConsent) {
        var updatedConsent = newConsent
        updatedConsent.hasAgreed = true
        updatedConsent.agreedDate = Date()
        self.consent = updatedConsent
        self.needsConsent = false
    }
    
    func revokeConsent() {
        self.consent = AnalyticsConsent()
        self.needsConsent = true
    }
    
    private func updateFirebaseAnalytics() {
        #if canImport(FirebaseAnalytics)
        Analytics.setAnalyticsCollectionEnabled(consent.hasAgreed)
        print("📊 Firebase Analytics collection: \(consent.hasAgreed ? "enabled" : "disabled")")
        #endif
    }
    
    // MARK: - Helper to log events to Firestore
    private func logEvent(name: String, parameters: [String: Any]) {
        guard consent.hasAgreed else { return }
        
        // Log to Firebase Analytics (for real-time dashboard)
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: parameters)
        print("📊 Logged to Firebase Analytics: \(name)")
        #endif
        
        // Also log to Firestore for long-term storage
        var eventData = parameters
        eventData["event_name"] = name
        eventData["timestamp"] = Timestamp(date: Date())
        
        db.collection("analytics_events").addDocument(data: eventData) { error in
            if let error = error {
                print("❌ Error logging to Firestore: \(error)")
            } else {
                print("📊 Logged to Firestore: \(name)")
            }
        }
    }
    
    // MARK: - Session Tracking
    func startSession() {
        guard consent.allowUsageStatistics else { return }
        sessionStartTime = Date()
        logEvent(name: "session_start", parameters: [:])
    }
    
    func endSession() {
        guard consent.allowUsageStatistics, let startTime = sessionStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        logEvent(name: "session_end", parameters: ["duration_seconds": Int(duration)])
        sessionStartTime = nil
    }
    
    // MARK: - Authentication Events
    func trackLogin(method: String, userId: String?) {
        guard consent.allowUsageStatistics else { return }
        var params: [String: Any] = ["method": method]
        if consent.allowPersonalization, let userId = userId {
            params["user_id"] = userId
        }
        logEvent(name: "login", parameters: params)
    }
    
    func trackSignUp(method: String, userId: String?) {
        guard consent.allowUsageStatistics else { return }
        var params: [String: Any] = ["method": method]
        if consent.allowPersonalization, let userId = userId {
            params["user_id"] = userId
        }
        logEvent(name: "sign_up", parameters: params)
    }
    
    func trackLogout() {
        guard consent.allowUsageStatistics else { return }
        logEvent(name: "logout", parameters: [:])
    }
    
    // MARK: - Gameplay Events
    func trackGameStart(level: Int, mode: String) {
        guard consent.allowGameplayTracking else { return }
        gameStartTime = Date()
        levelStartTime = Date()
        logEvent(name: "game_start", parameters: ["level": level, "mode": mode])
    }
    
    func trackLevelComplete(level: Int, mode: String, score: Int, turns: Int, timeRemaining: Int, isPerfect: Bool) {
        guard consent.allowGameplayTracking, let startTime = levelStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        logEvent(name: "level_complete", parameters: [
            "level": level,
            "mode": mode,
            "score": score,
            "turns": turns,
            "time_remaining": timeRemaining,
            "duration_seconds": Int(duration),
            "is_perfect": isPerfect
        ])
        levelStartTime = nil
    }
    
    func trackLevelFailed(level: Int, mode: String, score: Int, reason: String) {
        guard consent.allowGameplayTracking, let startTime = levelStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        logEvent(name: "level_failed", parameters: [
            "level": level,
            "mode": mode,
            "score": score,
            "duration_seconds": Int(duration),
            "failure_reason": reason
        ])
        levelStartTime = nil
    }
    
    func trackGameEnd(totalScore: Int, highestLevel: Int, totalPlayTime: TimeInterval) {
        guard consent.allowGameplayTracking else { return }
        logEvent(name: "game_end", parameters: [
            "total_score": totalScore,
            "highest_level": highestLevel,
            "total_play_time_seconds": Int(totalPlayTime)
        ])
        gameStartTime = nil
    }
    
    // MARK: - Score Events
    func trackHighScore(score: Int, level: Int, mode: String) {
        guard consent.allowGameplayTracking else { return }
        logEvent(name: "high_score", parameters: ["score": score, "level": level, "mode": mode])
    }
    
    // MARK: - Achievement Events
    func trackAchievementUnlocked(achievementId: String, achievementName: String) {
        guard consent.allowGameplayTracking else { return }
        logEvent(name: "achievement_unlocked", parameters: [
            "achievement_id": achievementId,
            "achievement_name": achievementName
        ])
    }
    
    // MARK: - Performance Events
    func trackPerformanceMetric(metric: String, value: Double, context: String) {
        guard consent.allowPerformanceTracking else { return }
        logEvent(name: "performance_metric", parameters: [
            "metric": metric,
            "value": value,
            "context": context
        ])
    }
    
    func trackMemoryWarning() {
        guard consent.allowPerformanceTracking else { return }
        logEvent(name: "memory_warning", parameters: [:])
    }
    
    // MARK: - Feature Usage
    func trackFeatureUsed(featureName: String, parameters: [String: Any]? = nil) {
        guard consent.allowUsageStatistics else { return }
        var params = parameters ?? [:]
        params["feature"] = featureName
        logEvent(name: "feature_used", parameters: params)
    }
    
    // MARK: - Error Tracking
    func trackError(error: Error, context: String) {
        guard consent.allowCrashReporting else { return }
        logEvent(name: "error_occurred", parameters: [
            "error_description": error.localizedDescription,
            "context": context
        ])
    }
    
    // MARK: - Screen Tracking
    func trackScreenView(screenName: String, screenClass: String) {
        guard consent.allowUsageStatistics else { return }
        logEvent(name: "screen_view", parameters: [
            "screen_name": screenName,
            "screen_class": screenClass
        ])
    }
    
    // MARK: - User Properties (stored in Firestore user document)
    func setUserProperty(property: String, value: String?) {
        guard consent.allowPersonalization else { return }
        print("📊 Would set user property: \(property) = \(value ?? "nil")")
    }
    
    func updateUserProperties(country: String?, level: Int?, totalScore: Int?) {
        guard consent.allowPersonalization else { return }
        var properties: [String: Any] = [:]
        if let country = country { properties["country"] = country }
        if let level = level { properties["highest_level"] = level }
        if let score = totalScore { properties["total_score"] = score }
        print("📊 Would update user properties: \(properties)")
    }
    
    // MARK: - VoiceOver Announcement Helper
    func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
