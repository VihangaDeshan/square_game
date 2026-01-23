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
                            
                            Button(action: {
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
                        }
                        
                        // Row 2: Difficult Mode (full width)
                        Button(action: {
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
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.15))
                    )
                    .padding(.horizontal, 30)
                    
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
