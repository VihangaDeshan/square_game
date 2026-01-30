import SwiftUI

struct HighScoresView: View {
    @ObservedObject var highScoreManager: HighScoreManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if highScoreManager.highScores.isEmpty {
                        emptyState
                    } else {
                        scoresList
                    }
                }
            }
            .navigationTitle("🏆 High Scores")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !highScoreManager.highScores.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All", role: .destructive) {
                            highScoreManager.clearAllScores()
                        }
                        .accessibilityLabel("Clear all high scores")
                        .accessibilityHint("Deletes all saved high scores")
                    }
                }
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No High Scores Yet")
                .font(.title2).bold()
            
            Text("Play some games to see your scores here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    var scoresList: some View {
        List {
            ForEach(Array(highScoreManager.highScores.enumerated()), id: \.element.id) { index, entry in
                HighScoreRow(entry: entry, rank: index + 1)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(rowColor(for: index))
                            .padding(.vertical, 2)
                    )
            }
        }
        .listStyle(.plain)
    }
    
    func rowColor(for index: Int) -> Color {
        switch index {
        case 0: return Color.yellow.opacity(0.3)
        case 1: return Color.gray.opacity(0.3)
        case 2: return Color.orange.opacity(0.3)
        default: return Color.white.opacity(0.5)
        }
    }
}

struct HighScoreRow: View {
    let entry: HighScoreEntry
    let rank: Int
    
    var body: some View {
        HStack {
            // Rank
            Text("\(rank)")
                .font(.title2).bold()
                .foregroundColor(rankColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                
                HStack {
                    Text("Level \(entry.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing) {
                Text("\(entry.score)")
                    .font(.title3).bold()
                    .foregroundColor(.blue)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank), \(entry.playerName), Score: \(entry.score) points, Level \(entry.level), Date: \(entry.date.formatted(date: .abbreviated, time: .omitted))")
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        headerSection
                        
                        gameplaySection
                        
                        peekingSection
                        
                        modesSection
                        
                        bonusLivesSection
                        
                        scoringSection
                    }
                    .padding()
                }
            }
            .navigationTitle("📖 How to Play")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome to Memory Color Match!")
                .font(.title2).bold()
            
            Text("Test your memory by matching colored cards in this classic puzzle game.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    var gameplaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Basic Gameplay", systemImage: "gamecontroller.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Match all pairs of colored cards on a 3×3 grid")
                bulletPoint("The center card is a bonus square (🌟) - already matched")
                bulletPoint("Tap two cards to reveal their colors")
                bulletPoint("If they match, they stay visible")
                bulletPoint("If not, they flip back after a short delay")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    var peekingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Peeking Feature", systemImage: "eye.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("At the start of each level, all cards flip over for 3 seconds")
                bulletPoint("Use this time to memorize the card positions")
                bulletPoint("After 3 seconds, cards flip back and the game begins")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    var modesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Game Modes", systemImage: "list.bullet")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score Mode (Levels 1-7)")
                        .font(.subheadline).bold()
                        .foregroundColor(.blue)
                    bulletPoint("⚠️ You MUST complete within max turns or level fails!")
                    bulletPoint("Fixed 3×3 grid for all levels")
                    bulletPoint("Level 1: 10 max turns")
                    bulletPoint("Level 2: 9 max turns")
                    bulletPoint("Level 3: 8 max turns")
                    bulletPoint("Level 4: 7 max turns")
                    bulletPoint("Level 5: 6 max turns")
                    bulletPoint("Level 6: 5 max turns")
                    bulletPoint("Level 7: 4 max turns (Perfect Score!)")
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time Mode")
                        .font(.subheadline).bold()
                        .foregroundColor(.orange)
                    bulletPoint("Find all matches before the timer runs out")
                    bulletPoint("30 seconds per level")
                    bulletPoint("Fixed 3×3 grid for all levels")
                    bulletPoint("Race against the clock!")
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🔥 Difficult Mode")
                            .font(.subheadline).bold()
                            .foregroundColor(.red)
                        Text("EXTREME CHALLENGE!")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.red))
                    }
                    
                    bulletPoint("⚡ Grid EXPANDS as you progress:")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("  • Levels 1-3: 3×3 grid (4 pairs)")
                            .font(.caption)
                        Text("  • Levels 4-6: 4×4 grid (8 pairs)")
                            .font(.caption)
                        Text("  • Levels 7-9: 5×5 grid (12 pairs)")
                            .font(.caption)
                        Text("  • Levels 10+: 6×6 grid (18 pairs)")
                            .font(.caption)
                    }
                    
                    bulletPoint("🔄 Colors SHUFFLE after EVERY match!")
                    bulletPoint("Matched pairs stay, but all other cards change colors")
                    bulletPoint("You must constantly re-adapt and re-memorize")
                    bulletPoint("45 seconds per level (vs 30 for time mode)")
                    bulletPoint("True test of working memory and pattern recognition")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    var bonusLivesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Bonus Lives 🌟", systemImage: "star.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Each level starts with 1 bonus life")
                bulletPoint("⭐ Complete with exactly 4 moves in 3×3 grids = Extra bonus life!")
                bulletPoint("If you run out of turns/time, the life is used automatically")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bonus Life Effects:")
                        .font(.subheadline)
                        .bold()
                        .padding(.top, 4)
                    Text("  • Score Mode: Grants 2 extra turns")
                        .font(.caption)
                    Text("  • Time Mode: Grants 10 extra seconds")
                        .font(.caption)
                    Text("  • Difficult Mode: Grants 10 extra seconds")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    var scoringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Scoring System", systemImage: "number.circle.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score & Time Modes:")
                        .font(.subheadline)
                        .bold()
                    bulletPoint("Base: 100 points per match")
                    bulletPoint("Bonus for unused turns in Score Mode")
                    bulletPoint("Bonus for remaining time in Time Mode")
                    bulletPoint("Level multiplier: 50 points × level number")
                    bulletPoint("Perfect game (4 moves): 200 point bonus!")
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Difficult Mode:")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.red)
                    bulletPoint("Base: 150 points per match (higher!)")
                    bulletPoint("Time bonus: 15 points per remaining second")
                    bulletPoint("Level multiplier: 75 points × level number")
                    bulletPoint("Shuffle penalty: -5 points per shuffle")
                    bulletPoint("Larger grids = more points potential")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
    
    func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    InfoView()
}
