import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var highScoreManager = HighScoreManager()
    
    @State private var showHighScores = false
    @State private var showInfo = false
    
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
            
            VStack(spacing: 30) {
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
                        viewModel.startNewGame(level: 1)
                    }
                    
                    MenuButton(
                        icon: "list.bullet.circle.fill",
                        title: "Select Mode",
                        subtitle: "Choose Score or Time Mode",
                        color: .blue
                    ) {
                        // Show mode selection
                    }
                    .overlay(
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.startInMode(.score)
                            }) {
                                VStack {
                                    Image(systemName: "number.circle.fill")
                                        .font(.title2)
                                    Text("Score")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.startInMode(.time)
                            }) {
                                VStack {
                                    Image(systemName: "timer.circle.fill")
                                        .font(.title2)
                                    Text("Time")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 60)
                    )
                    
                    MenuButton(
                        icon: "trophy.circle.fill",
                        title: "High Scores",
                        subtitle: "View Top Players",
                        color: .orange
                    ) {
                        showHighScores = true
                    }
                    
                    MenuButton(
                        icon: "info.circle.fill",
                        title: "How to Play",
                        subtitle: "Learn the Rules",
                        color: .purple
                    ) {
                        showInfo = true
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                Text("Made with ❤️ in SwiftUI")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
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
    }
}

#Preview {
    ContentView()
}
