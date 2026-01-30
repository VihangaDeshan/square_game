import SwiftUI

// MARK: - Achievements View
struct AchievementsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) var dismiss
    
    var achievements: [Achievement] {
        let defaultAchievements = firebaseManager.getDefaultAchievements()
        let unlockedIds = firebaseManager.userProfile?.achievements ?? []
        
        return defaultAchievements.map { achievement in
            var updatedAchievement = achievement
            updatedAchievement.isUnlocked = unlockedIds.contains(achievement.id)
            return updatedAchievement
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress Header
                        VStack(spacing: 10) {
                            Text("🏅 Achievements")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("\(unlockedCount) / \(achievements.count) Unlocked")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * CGFloat(unlockedCount) / CGFloat(achievements.count),
                                            height: 20
                                        )
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.9))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Achievements Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(achievements) { achievement in
                                AchievementCardView(achievement: achievement)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Card View
struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AnyShapeStyle(iconColor.gradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
                    .frame(width: 70, height: 70)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 35))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Title
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Description
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Status
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("Unlocked")
                        .font(.caption2)
                }
                .foregroundColor(.green)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text("Locked")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(height: 220)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(
                    color: achievement.isUnlocked ? iconColor.opacity(0.3) : Color.clear,
                    radius: achievement.isUnlocked ? 8 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    achievement.isUnlocked ? iconColor.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .animation(.spring(), value: achievement.isUnlocked)
    }
    
    var iconColor: Color {
        switch achievement.type {
        case .firstWin:
            return .green
        case .perfectGame:
            return .yellow
        case .speedster:
            return .orange
        case .marathonRunner:
            return .blue
        case .levelMaster:
            return .purple
        case .scoreHunter:
            return .red
        case .matchMaker:
            return .pink
        case .survivor:
            return .cyan
        case .difficultChampion:
            return Color(red: 0.5, green: 0.0, blue: 0.5)
        case .timeWizard:
            return .mint
        }
    }
}

// MARK: - Achievement Unlocked Popup
struct AchievementUnlockedView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.yellow.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("🎉 Achievement Unlocked! 🎉")
                .font(.title3)
                .fontWeight(.bold)
            
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(.orange)
            
            Text(achievement.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Awesome!") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
        .padding()
    }
}

// MARK: - Preview
struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environmentObject(FirebaseManager.shared)
    }
}
