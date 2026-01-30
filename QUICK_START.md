# 🚀 Quick Start Guide - Firebase Integration

## What's New?

Your Memory Color Match game now has:
✅ **User Authentication** - Login/Register system
✅ **Global Leaderboards** - Compete worldwide
✅ **Regional Leaderboards** - Compete in your country
✅ **Achievements** - 10 achievements to unlock
✅ **Auto-Progression** - Levels advance automatically after 5 seconds
✅ **Continuous Gameplay** - No interruptions!

## 📋 Before You Start

You need to:
1. Have Xcode installed
2. Have a Google account (for Firebase)
3. 15-20 minutes to complete setup

## 🔥 Firebase Setup (5 Steps)

### Step 1: Create Firebase Project (3 minutes)
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name it "MemoryColorMatch"
4. Click through the setup (you can disable Analytics)

### Step 2: Add iOS App (2 minutes)
1. In Firebase Console, click the iOS icon
2. Enter your bundle ID from Xcode (e.g., `com.yourname.square-game`)
3. Click "Register app"
4. **Download `GoogleService-Info.plist`**

### Step 3: Add Firebase Config to Xcode (2 minutes)
1. Open your Xcode project
2. Drag `GoogleService-Info.plist` into the `square_game` folder
3. ✅ Check "Copy items if needed"
4. ✅ Make sure it's added to the target

### Step 4: Install Firebase SDK (5 minutes)
1. In Xcode: File → Add Package Dependencies
2. Paste: `https://github.com/firebase/firebase-ios-sdk.git`
3. Click "Add Package"
4. Select these packages:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseCore
5. Click "Add Package" and wait for installation

### Step 5: Enable Services in Firebase (5 minutes)

#### Enable Authentication:
1. Firebase Console → **Authentication**
2. Click "Get started"
3. Click "Email/Password" → Enable → Save

#### Enable Firestore:
1. Firebase Console → **Firestore Database**
2. Click "Create database"
3. Select "Start in test mode"
4. Choose location (closest to you)
5. Click "Enable"

#### Create Indexes (Important!):
1. Go to **Firestore** → **Indexes** tab
2. Click "Create index" and add these 3 indexes:

**Index 1 - Global Leaderboard:**
- Collection: `scores`
- Field 1: `score` (Descending)
- Field 2: `timestamp` (Descending)

**Index 2 - Regional Leaderboard:**
- Collection: `scores`
- Field 1: `country` (Ascending)
- Field 2: `score` (Descending)
- Field 3: `timestamp` (Descending)

**Index 3 - User History:**
- Collection: `scores`
- Field 1: `userId` (Ascending)
- Field 2: `timestamp` (Descending)

## ✅ That's It! Now Run Your App

1. Clean build: Cmd+Shift+K
2. Build: Cmd+B
3. Run: Cmd+R

## 🎮 How to Use

### First Time:
1. App opens to Register screen
2. Enter email, password, username, country
3. Click "Register"
4. You're in! Start playing!

### Playing:
1. Complete a level
2. **Wait 5 seconds** → Auto-advances to next level
3. OR click "Next Level Now" to skip countdown
4. Scores save automatically!

### View Leaderboards:
1. Main menu → "Leaderboard" button
2. See Global, Regional, or Your Scores tabs
3. Compete with players worldwide!

### Check Achievements:
1. Main menu → "Achievements" button
2. See what you've unlocked
3. 10 achievements to collect!

## 🏆 Achievements List

1. 🌟 **First Victory** - Complete your first level
2. 👑 **Perfect Memory** - Complete with 4 turns
3. ⚡ **Speedster** - Complete 5 time mode levels
4. 🏃 **Marathon Runner** - Play 50 games
5. 🏁 **Level Master** - Reach level 10
6. 🎯 **Score Hunter** - Get 10,000 total points
7. ❤️ **Match Maker** - Find 500 matches
8. 🛡️ **Survivor** - Use a bonus life and win
9. 🔥 **Difficult Champion** - Complete 10 difficult levels
10. ⏰ **Time Wizard** - Finish with 20+ seconds left

## 🆘 Troubleshooting

**App crashes on launch?**
→ Check that `GoogleService-Info.plist` is in project and copied correctly

**Can't register/login?**
→ Make sure Email/Password is enabled in Firebase Console

**Scores not showing?**
→ Create the 3 required indexes in Firestore (see above)

**Auto-progression not working?**
→ Just wait 5 seconds after winning/losing - it will advance automatically!

## 📱 Test It!

1. Register 2-3 test accounts
2. Play some games
3. Check if scores appear in leaderboard
4. Try to unlock achievements
5. Let the 5-second countdown complete to test auto-progression

## 🎨 New Features Summary

### Auto-Progression (NEW!)
- ✅ No more clicking "Next Level" after every game
- ✅ 5-second countdown with progress bar
- ✅ Can skip countdown anytime
- ✅ Works for both wins and losses (retry)
- ✅ Seamless, continuous gameplay

### Leaderboards (NEW!)
- ✅ Global rankings
- ✅ Regional rankings by country
- ✅ Personal score history
- ✅ Real-time updates
- ✅ Beautiful UI with medals for top 3

### Achievements (NEW!)
- ✅ 10 achievements to unlock
- ✅ Progress tracking
- ✅ Visual unlocked/locked states
- ✅ Syncs across devices

### User System (NEW!)
- ✅ Email/password login
- ✅ Persistent sessions
- ✅ User profiles
- ✅ Sign out option

## 📚 More Help?

See these files for detailed information:
- `FIREBASE_SETUP.md` - Complete Firebase setup guide
- `IMPLEMENTATION_SUMMARY.md` - Technical details

## 🎉 You're All Set!

Your game now has:
- Professional user authentication
- Competitive global leaderboards
- Achievement system
- Smooth auto-progressing gameplay

**Have fun and compete for the top spot!** 🏆

---

Need help? Check the troubleshooting section above or review the detailed setup guide in `FIREBASE_SETUP.md`.
