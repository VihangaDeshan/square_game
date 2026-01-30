# 🧠 Memory Color Match - Firebase Edition

A SwiftUI memory matching game with Firebase integration for global leaderboards, achievements, and user authentication.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2015.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-10.0+-yellow.svg)

## ✨ Features

### 🎮 Core Gameplay
- **3 Game Modes:**
  - **Score Mode**: Complete levels with limited moves (Levels 1-7)
  - **Time Mode**: Race against the clock (30 seconds per level)
  - **Difficult Mode**: Expanding grids with shuffling colors after each match
- **Dynamic Grid Sizes**: 3×3 up to 6×6 for difficult mode
- **Bonus Lives**: Earn extra lives for perfect games (4 turns)
- **Beautiful Animations**: Smooth card flips and transitions
- **Peek Phase**: 3-second memorization period before each level

### 🔥 Firebase Features

#### 👤 User Authentication
- Email/Password registration and login
- Persistent user sessions
- User profiles with username and country
- Automatic first-time user registration prompt
- Sign out functionality

#### 🏆 Leaderboards
- **Global Leaderboard**: Compete with players worldwide (Top 100)
- **Regional Leaderboard**: Compete within your country (Top 100)
- **Personal Score History**: Track your last 100 games
- Real-time score syncing
- Beautiful rank badges (🥇🥈🥉 for top 3)
- Country flags and timestamps

#### 🎯 Achievements System
10 achievements to unlock:
1. 🌟 **First Victory** - Complete your first level
2. 👑 **Perfect Memory** - Complete a level with 4 turns
3. ⚡ **Speedster** - Complete 5 time mode levels
4. 🏃 **Marathon Runner** - Play 50 games
5. 🏁 **Level Master** - Reach level 10
6. 🎯 **Score Hunter** - Accumulate 10,000 total points
7. ❤️ **Match Maker** - Find 500 matches
8. 🛡️ **Survivor** - Use a bonus life and win
9. 🔥 **Difficult Champion** - Complete 10 difficult mode levels
10. ⏰ **Time Wizard** - Finish with 20+ seconds remaining

### ⚡ Auto-Progression (NEW!)
- **No interruptions** between levels
- 5-second countdown with progress bar
- Auto-advances to next level after win
- Auto-retries level after loss
- Option to skip countdown anytime
- Seamless, continuous gameplay experience

## 📱 Screenshots

[Add your screenshots here]

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+
- Firebase account
- CocoaPods or Swift Package Manager

### Quick Setup (5 Steps)

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/square_game.git
   cd square_game
   ```

2. **Set up Firebase** (15 minutes)
   - Follow the detailed guide in [`QUICK_START.md`](QUICK_START.md)
   - Or see [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) for complete instructions

3. **Install Firebase SDK**
   - In Xcode: File → Add Package Dependencies
   - URL: `https://github.com/firebase/firebase-ios-sdk.git`
   - Select: FirebaseAuth, FirebaseFirestore, FirebaseCore

4. **Add Firebase Config**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add to Xcode project (replace template file)

5. **Build and Run**
   ```bash
   # Clean build
   Cmd + Shift + K
   
   # Build
   Cmd + B
   
   # Run
   Cmd + R
   ```

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get up and running in 15 minutes
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete Firebase configuration guide
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Technical implementation details

## 🏗️ Project Structure

```
square_game/
├── square_gameApp.swift          # App entry point with Firebase init
├── ContentView.swift              # Main menu with user profile
├── GameView.swift                 # Game screen with auto-progression
├── GameViewModel.swift            # Game logic and achievement tracking
├── GameModel.swift                # Data models
├── FirebaseManager.swift          # Firebase service manager
├── AuthenticationView.swift       # Login/Register UI
├── LeaderboardView.swift          # Global/Regional leaderboards
├── AchievementsView.swift         # Achievement tracking UI
├── SupportingViews.swift          # UI components
├── HighScoreManager.swift         # Local high scores
└── GoogleService-Info.plist       # Firebase config (not in repo)
```

## 🗄️ Firebase Database Structure

### Users Collection
```json
{
  "userId": {
    "username": "string",
    "email": "string",
    "country": "string",
    "totalScore": "number",
    "gamesPlayed": "number",
    "highestLevel": "number",
    "achievements": ["array"],
    "createdAt": "timestamp",
    "lastPlayed": "timestamp"
  }
}
```

### Scores Collection
```json
{
  "scoreId": {
    "userId": "string",
    "username": "string",
    "country": "string",
    "score": "number",
    "level": "number",
    "mode": "string",
    "timestamp": "timestamp"
  }
}
```

## 🎮 How to Play

1. **Register/Login** on first launch
2. **Choose a game mode** from the main menu
3. **Memorize colors** during the 3-second peek phase
4. **Match cards** by tapping to flip them
5. **Complete the level** within turn/time limits
6. **Wait 5 seconds** or click "Next Level Now"
7. **Compete** on global and regional leaderboards!
8. **Unlock achievements** as you play

## 🔐 Security

- ⚠️ Never commit `GoogleService-Info.plist` to version control
- ⚠️ Update Firestore security rules for production
- ⚠️ Enable Firebase App Check for additional security
- ✅ Template file provided: `GoogleService-Info-TEMPLATE.plist`
- ✅ `.gitignore` configured to exclude sensitive files

## 🛠️ Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for timers
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Firebase iOS SDK** - Backend integration

## 📊 Features Breakdown

| Feature | Status | Description |
|---------|--------|-------------|
| User Authentication | ✅ | Email/Password with Firebase Auth |
| Global Leaderboard | ✅ | Top 100 scores worldwide |
| Regional Leaderboard | ✅ | Top 100 by country |
| Score History | ✅ | Personal last 100 games |
| Achievements | ✅ | 10 unlockable achievements |
| Auto-Progression | ✅ | 5-second countdown between levels |
| User Profiles | ✅ | Track stats and progress |
| Offline Mode | ❌ | Coming soon |
| Push Notifications | ❌ | Coming soon |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Created by COBSCCOMP24.2P-008

## 🙏 Acknowledgments

- SwiftUI for the amazing UI framework
- Firebase for backend services
- The iOS development community

## 📞 Support

If you have any questions or run into issues:
1. Check [`QUICK_START.md`](QUICK_START.md) for common setup issues
2. Review [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) for detailed configuration
3. Open an issue on GitHub

## 🎯 Roadmap

- [ ] Offline gameplay support
- [ ] Push notifications for achievements
- [ ] Friend system and challenges
- [ ] More game modes
- [ ] Daily challenges
- [ ] Custom themes
- [ ] Sound effects and music
- [ ] iPad optimization

---

**Made with ❤️ and SwiftUI**

⭐ Star this repo if you found it helpful!
