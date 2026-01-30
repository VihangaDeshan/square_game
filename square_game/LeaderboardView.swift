import SwiftUI

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    @State private var globalScores: [ScoreEntry] = []
    @State private var regionalScores: [ScoreEntry] = []
    @State private var userScores: [ScoreEntry] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    Picker("Leaderboard Type", selection: $selectedTab) {
                        Text("Global").tag(0)
                        Text("Regional").tag(1)
                        Text("My Scores").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .accessibilityLabel("Leaderboard type")
                    .accessibilityHint("Choose between global, regional, or your scores")
                    
                    // Content
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else {
                        TabView(selection: $selectedTab) {
                            // Global Leaderboard
                            leaderboardList(scores: globalScores)
                                .tag(0)
                            
                            // Regional Leaderboard
                            leaderboardList(scores: regionalScores)
                                .tag(1)
                            
                            // User Score History
                            userScoreHistoryList()
                                .tag(2)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
            }
            .navigationTitle("🏆 Leaderboards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        loadLeaderboards()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh leaderboards")
                    .accessibilityHint("Reload all leaderboard data")
                }
            }
            .onAppear {
                loadLeaderboards()
            }
        }
    }
    
    // MARK: - Leaderboard List
    func leaderboardList(scores: [ScoreEntry]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if scores.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No scores yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Be the first to set a score!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                        LeaderboardRowView(score: score, rank: index + 1)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - User Score History List
    func userScoreHistoryList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if userScores.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No scores yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Play a game to see your scores!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(userScores) { score in
                        UserScoreRowView(score: score)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Load Leaderboards
    func loadLeaderboards() {
        isLoading = true
        
        Task {
            do {
                // Load global leaderboard
                let global = try await firebaseManager.fetchGlobalLeaderboard(limit: 100)
                
                // Load regional leaderboard
                let regional: [ScoreEntry]
                if let country = firebaseManager.userProfile?.country {
                    regional = try await firebaseManager.fetchRegionalLeaderboard(country: country, limit: 100)
                } else {
                    regional = []
                }
                
                // Load user scores
                let user = try await firebaseManager.fetchUserScoreHistory()
                
                await MainActor.run {
                    globalScores = global
                    regionalScores = regional
                    userScores = user
                    isLoading = false
                }
            } catch {
                print("Error loading leaderboards: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Leaderboard Row View
struct LeaderboardRowView: View {
    let score: ScoreEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.gradient)
                    .frame(width: 45, height: 45)
                
                if rank <= 3 {
                    Text(rankEmoji)
                        .font(.title2)
                } else {
                    Text("#\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(score.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(countryFlag(score.country))
                        .font(.caption)
                }
                
                HStack(spacing: 8) {
                    Label("\(score.score)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Label("Lvl \(score.level)", systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(score.mode)
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            Spacer()
            
            // Timestamp
            Text(timeAgo(score.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: rankColor.opacity(0.3), radius: rank <= 3 ? 5 : 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank), \(score.username) from \(score.country), Score: \(score.score), Level: \(score.level), Mode: \(score.mode), \(timeAgo(score.timestamp))")
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    func countryFlag(_ country: String) -> String {
        let flags: [String: String] = [
            "USA": "🇺🇸", "UK": "🇬🇧", "Canada": "🇨🇦", "Australia": "🇦🇺",
            "India": "🇮🇳", "Germany": "🇩🇪", "France": "🇫🇷", "Japan": "🇯🇵",
            "China": "🇨🇳", "Brazil": "🇧🇷"
        ]
        return flags[country] ?? "🌍"
    }
    
    func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}

// MARK: - User Score Row View
struct UserScoreRowView: View {
    let score: ScoreEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Score Icon
            ZStack {
                Circle()
                    .fill(modeColor.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: modeIcon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Score Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(score.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text(score.mode)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(modeColor.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(modeColor)
                }
                
                HStack {
                    Label("Level \(score.level)", systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(formatDate(score.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 2)
        )
    }
    
    var modeColor: Color {
        switch score.mode {
        case "Score Mode": return .blue
        case "Time Mode": return .orange
        case "Difficult Mode": return .purple
        default: return .gray
        }
    }
    
    var modeIcon: String {
        switch score.mode {
        case "Score Mode": return "number.circle.fill"
        case "Time Mode": return "timer"
        case "Difficult Mode": return "flame.fill"
        default: return "star.fill"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .environmentObject(FirebaseManager.shared)
    }
}
