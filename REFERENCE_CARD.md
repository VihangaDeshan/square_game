# 📋 Quick Reference Card

## 🔥 Firebase Setup - 5 Steps
1. Create Firebase project → https://console.firebase.google.com/
2. Add iOS app → Enter bundle ID
3. Download `GoogleService-Info.plist` → Add to Xcode
4. Install Firebase SDK → `https://github.com/firebase/firebase-ios-sdk.git`
5. Enable Auth + Firestore → Create 3 indexes

## 📦 Required Firebase Packages
- ✅ FirebaseCore
- ✅ FirebaseAuth  
- ✅ FirebaseFirestore

## 🗄️ Firestore Indexes (Required!)

**Global Leaderboard:**
- Collection: `scores`
- Fields: `score` DESC, `timestamp` DESC

**Regional Leaderboard:**
- Collection: `scores`
- Fields: `country` ASC, `score` DESC, `timestamp` DESC

**User History:**
- Collection: `scores`
- Fields: `userId` ASC, `timestamp` DESC

## 🎮 New Features

### Auto-Progression
- ⏱️ 5-second countdown after each level
- ⚡ Auto-advances on win
- 🔄 Auto-retries on loss
- ⏭️ Skip button available

### Leaderboards
- 🌍 Global (Top 100)
- 🏴 Regional by country
- 📊 Personal score history

### Achievements
- 🎯 10 total achievements
- ⭐ Auto-unlock on completion
- 🔄 Syncs to Firebase

## 📱 User Flow
```
Launch → Auth → Menu → Play → Auto-Progress → Repeat
```

## 🏆 10 Achievements
1. First Victory - Complete first level
2. Perfect Memory - 4 turns
3. Speedster - 5 time levels
4. Marathon Runner - 50 games
5. Level Master - Level 10
6. Score Hunter - 10K points
7. Match Maker - 500 matches
8. Survivor - Use bonus life
9. Difficult Champion - 10 difficult levels
10. Time Wizard - 20+ seconds left

## 📁 Key Files

**Created:**
- `FirebaseManager.swift` - Core Firebase logic
- `AuthenticationView.swift` - Login/Register
- `LeaderboardView.swift` - Rankings
- `AchievementsView.swift` - Achievements
- `FIREBASE_SETUP.md` - Setup guide

**Modified:**
- `square_gameApp.swift` - Firebase init
- `GameViewModel.swift` - Auto-progress
- `GameView.swift` - Countdown UI
- `ContentView.swift` - New buttons

## 🔧 Quick Commands

**Clean Build:**
```
Cmd + Shift + K
```

**Build:**
```
Cmd + B
```

**Run:**
```
Cmd + R
```

## 🆘 Troubleshooting

**App crashes?**
→ Check `GoogleService-Info.plist` is added

**Can't login?**
→ Enable Email/Password in Firebase Console

**No scores?**
→ Create Firestore indexes

**No auto-progress?**
→ Wait 5 seconds after game ends

## 📚 Documentation

- `QUICK_START.md` - 15-min setup
- `FIREBASE_SETUP.md` - Complete guide
- `TESTING_CHECKLIST.md` - Test everything
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `README.md` - Project overview

## ⚡ Speed Run Setup (Experienced Devs)

1. Clone repo
2. Firebase Console → Create project → Add iOS app
3. Download plist → Add to Xcode
4. SPM → Add Firebase SDK (Auth, Firestore, Core)
5. Firebase Console → Enable Email/Password
6. Firestore → Create DB → Add 3 indexes
7. Build & Run
8. Register test user
9. Play & verify

**Time: 10-15 minutes**

## 🎯 Testing Priority

**Must Test:**
1. ✅ Registration & login
2. ✅ Auto-progression (5-sec countdown)
3. ✅ Score saves to leaderboard
4. ✅ Achievements unlock

**Should Test:**
5. Regional leaderboard filtering
6. Score history display
7. Sign out functionality

## 🔒 Security Checklist

Before production:
- [ ] Update Firestore rules
- [ ] Enable App Check
- [ ] Add `.gitignore` for plist
- [ ] Review Firebase console settings

## 📊 Database Collections

**users/{userId}**
- username, email, country
- totalScore, gamesPlayed, highestLevel
- achievements[], createdAt, lastPlayed

**scores/{scoreId}**
- userId, username, country
- score, level, mode, timestamp

## 🎨 UI Updates

**Main Menu:**
- User profile at top
- Leaderboard button
- Achievements button
- Sign out button

**Game Screens:**
- Win overlay: countdown + progress bar
- Loss overlay: countdown + retry
- Skip buttons

## ⚙️ Configuration

**Bundle ID:** Set in Xcode
**Firebase Config:** `GoogleService-Info.plist`
**Min iOS:** 15.0+
**Swift:** 5.9+

## 🚀 Deploy Checklist

1. ✅ All tests pass
2. ✅ Firebase configured
3. ✅ Indexes created
4. ✅ Security rules updated
5. ✅ App icons added
6. ✅ Version bumped
7. ✅ TestFlight build
8. ✅ Submit to App Store

---

**Keep this card handy for quick reference!**

Full docs in: `QUICK_START.md` | `FIREBASE_SETUP.md`
