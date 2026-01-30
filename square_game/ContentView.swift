import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var highScoreManager = HighScoreManager()
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @EnvironmentObject var analyticsManager: AnalyticsManager
    
    @State private var showHighScores = false
    @State private var showInfo = false
    @State private var showLeaderboard = false
    @State private var showAchievements = false
    @State private var showCountryPicker = false
    @State private var showAccessibilitySettings = false
    @State private var showPrivacySettings = false
    
    var body: some View {
        ZStack {
            if viewModel.gameState == .menu {
                mainMenu
            } else {
                GameView(viewModel: viewModel, highScoreManager: highScoreManager)
            }
        }
        .sheet(isPresented: $showHighScores) {
            HighScoresView(highScoreManager: highScoreManager)
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
                .environmentObject(firebaseManager)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(firebaseManager)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView()
                .environmentObject(firebaseManager)
        }
        .sheet(isPresented: $showAccessibilitySettings) {
            AccessibilitySettingsView()
                .environmentObject(accessibilityManager)
        }
        .sheet(isPresented: $showPrivacySettings) {
            AnalyticsConsentView()
                .environmentObject(analyticsManager)
                .environmentObject(accessibilityManager)
        }
        .onAppear {
            // Refresh profile when view appears
            Task {
                await firebaseManager.refreshUserProfile()
            }
        }
    }
    
    // Helper function to get country flag
    private func getCountryFlag(_ country: String) -> String {
        let flags: [String: String] = [
            "USA": "🇺🇸",
            "UK": "🇬🇧",
            "Canada": "🇨🇦",
            "Australia": "🇦🇺",
            "India": "🇮🇳",
            "Germany": "🇩🇪",
            "France": "🇫🇷",
            "Japan": "🇯🇵",
            "China": "🇨🇳",
            "Brazil": "🇧🇷",
            "Sri Lanka": "🇱🇰",
            "Other": "🌍"
        ]
        return flags[country] ?? "🌍"
    }
    
    var mainMenu: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Always visible logout button at top-right
                HStack {
                    Spacer()
                    Menu {
                        // Show current country
                        if let profile = firebaseManager.userProfile {
                            Section {
                                Text("Country: \(profile.country)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            showCountryPicker = true
                        }) {
                            Label("Change Country", systemImage: "flag.fill")
                        }
                        
                        Button(action: {
                            Task {
                                await firebaseManager.refreshUserProfile()
                            }
                        }) {
                            Label("Refresh Profile", systemImage: "arrow.clockwise")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            do {
                                analyticsManager.trackLogout()
                                try firebaseManager.signOut()
                            } catch {
                                print("Error signing out: \(error)")
                                analyticsManager.trackError(error: error, context: "logout")
                            }
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.3)))
                    }
                    .accessibilityLabel("Profile menu")
                    .accessibilityHint("Opens profile options")
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer().frame(height: 10)
                
                ScrollView {
                    VStack(spacing: 30) {
                // User Profile Header
                if let userProfile = firebaseManager.userProfile {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome, \(userProfile.username)!")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                Text(getCountryFlag(userProfile.country))
                                    .font(.caption)
                                Text(userProfile.country)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("•")
                                    .foregroundColor(.white.opacity(0.5))
                                Text("Lvl \(userProfile.highestLevel)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("•")
                                    .foregroundColor(.white.opacity(0.5))
                                Text("\(userProfile.totalScore) pts")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Welcome \(userProfile.username). Country: \(userProfile.country). Highest level: \(userProfile.highestLevel). Total score: \(userProfile.totalScore) points")
                        Spacer()
                        Button(action: {
                            do {
                                try firebaseManager.signOut()
                            } catch {
                                print("Error signing out: \(error)")
                            }
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                } else if firebaseManager.isAuthenticated {
                    // Show logout button even without profile
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Loading profile...")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Tap refresh if stuck")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Button(action: {
                            Task {
                                await firebaseManager.refreshUserProfile()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        Button(action: {
                            do {
                                try firebaseManager.signOut()
                            } catch {
                                print("Error signing out: \(error)")
                            }
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.3))
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Title
                VStack(spacing: 10) {
                    Text("🧠")
                        .font(.system(size: 80))
                    
                    Text("Memory Color Match")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Text("Test Your Memory!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Menu buttons
                VStack(spacing: 20) {
                    MenuButton(
                        icon: "play.circle.fill",
                        title: "Start Game",
                        subtitle: "Begin Level 1",
                        color: .green
                    ) {
                        accessibilityManager.playButtonTapSound()
                        analyticsManager.trackFeatureUsed(featureName: "start_game", parameters: ["entry_point": "main_menu"])
                        viewModel.startNewGame(level: 1)
                    }
                    
                    // Mode Selection Section
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("Select Mode")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Row 1: Score and Time
                        HStack(spacing: 12) {
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                viewModel.startInMode(.score)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "number.circle.fill")
                                        .font(.system(size: 28))
                                    Text("Score")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Levels 1-7")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.gradient)
                                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 3)
                                )
                            }
                            .accessibilityLabel("Score mode")
                            .accessibilityHint("Play levels 1 through 7")
                            
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                viewModel.startInMode(.time)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "timer.circle.fill")
                                        .font(.system(size: 28))
                                    Text("Time")
                                        .font(.subheadline)
                                        .bold()
                                    Text("30 sec/level")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.gradient)
                                        .shadow(color: Color.orange.opacity(0.5), radius: 5, x: 0, y: 3)
                                )
                            }
                            .accessibilityLabel("Time mode")
                            .accessibilityHint("Complete levels within 30 seconds each")
                        }
                        
                        // Row 2: Difficult Mode (full width)
                        Button(action: {
                            accessibilityManager.playButtonTapSound()
                            viewModel.startInMode(.difficult)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.circle.fill")
                                    .font(.system(size: 28))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Difficult Mode")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Expanding grid • Colors shuffle after match")
                                        .font(.caption2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red, Color.purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.red.opacity(0.5), radius: 5, x: 0, y: 3)
                            )
                        }
                        .accessibilityLabel("Difficult mode")
                        .accessibilityHint("Play with expanding grid and shuffling colors")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.15))
                    )
                    .padding(.horizontal, 30)
                    
                    // Firebase Leaderboards and Achievements
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "cloud.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("Online Features")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                analyticsManager.trackScreenView(screenName: "Leaderboard", screenClass: "LeaderboardView")
                                analyticsManager.trackFeatureUsed(featureName: "view_leaderboard")
                                showLeaderboard = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 28))
                                    Text("Leaderboard")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Global & Regional")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.gradient)
                                        .shadow(color: Color.green.opacity(0.5), radius: 5, x: 0, y: 3)
                                )
                            }
                            .accessibilityLabel("Leaderboard")
                            .accessibilityHint("View global and regional high scores")
                            
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                analyticsManager.trackScreenView(screenName: "Achievements", screenClass: "AchievementsView")
                                analyticsManager.trackFeatureUsed(featureName: "view_achievements")
                                showAchievements = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "rosette")
                                        .font(.system(size: 28))
                                    Text("Achievements")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Track Progress")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.yellow.gradient)
                                        .shadow(color: Color.yellow.opacity(0.5), radius: 5, x: 0, y: 3)
                                )
                            }
                            .accessibilityLabel("Achievements")
                            .accessibilityHint("View unlocked achievements and progress")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.15))
                    )
                    .padding(.horizontal, 30)
                    
                    MenuButton(
                        icon: "trophy.circle.fill",
                        title: "Local High Scores",
                        subtitle: "View Top Players",
                        color: .orange
                    ) {
                        accessibilityManager.playButtonTapSound()
                        showHighScores = true
                    }
                    
                    MenuButton(
                        icon: "info.circle.fill",
                        title: "How to Play",
                        subtitle: "Learn the Rules",
                        color: .purple
                    ) {
                        accessibilityManager.playButtonTapSound()
                        showInfo = true
                    }
                    
                    MenuButton(
                        icon: "accessibility",
                        title: "Accessibility Settings",
                        subtitle: "Customize Experience",
                        color: .cyan
                    ) {
                        accessibilityManager.playButtonTapSound()
                        showAccessibilitySettings = true
                    }
                    
                    MenuButton(
                        icon: "hand.raised.fill",
                        title: "Privacy & Data",
                        subtitle: "Manage Data Collection",
                        color: .indigo
                    ) {
                        accessibilityManager.playButtonTapSound()
                        analyticsManager.trackFeatureUsed(featureName: "view_privacy_settings")
                        showPrivacySettings = true
                    }
                }
                .padding(.horizontal, 30)
                
                // Footer
                Text("Made with ❤️ in SwiftUI")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Menu Button Component
struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

// MARK: - Country Picker View
struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let countries = ["USA", "UK", "Canada", "Australia", "India", "Germany", "France", "Japan", "China", "Brazil", "Sri Lanka", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {
                    Section {
                        ForEach(countries, id: \.self) { country in
                            Button(action: {
                                Task {
                                    await firebaseManager.updateUserCountry(country)
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Text(getCountryFlag(country))
                                        .font(.title2)
                                        .accessibilityHidden(true)
                                    Text(country)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if firebaseManager.userProfile?.country == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                            .accessibilityLabel(country + (firebaseManager.userProfile?.country == country ? ", selected" : ""))
                            .accessibilityHint("Double tap to select \(country)")
                        }
                    } header: {
                        Text("Select Your Country")
                    } footer: {
                        Text("This will be displayed on leaderboards")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Change Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getCountryFlag(_ country: String) -> String {
        let flags: [String: String] = [
            "USA": "🇺🇸",
            "UK": "🇬🇧",
            "Canada": "🇨🇦",
            "Australia": "🇦🇺",
            "India": "🇮🇳",
            "Germany": "🇩🇪",
            "France": "🇫🇷",
            "Japan": "🇯🇵",
            "China": "🇨🇳",
            "Brazil": "🇧🇷",
            "Sri Lanka": "🇱🇰",
            "Other": "🌍"
        ]
        return flags[country] ?? "🌍"
    }
}

