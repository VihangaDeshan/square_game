# 🧪 Testing Checklist

Use this checklist to verify all features are working correctly after Firebase integration.

## 📋 Pre-Testing Setup

- [ ] Firebase project created
- [ ] iOS app added to Firebase
- [ ] `GoogleService-Info.plist` downloaded and added to Xcode
- [ ] Firebase SDK installed (FirebaseAuth, FirebaseFirestore, FirebaseCore)
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Firestore database created
- [ ] All 3 required indexes created in Firestore
- [ ] Project builds without errors

## 🔐 Authentication Testing

### New User Registration
- [ ] App launches to registration screen (first time)
- [ ] Can enter email, password, username, country
- [ ] Registration validates all fields are filled
- [ ] Registration succeeds with valid credentials
- [ ] Registration fails with invalid email format
- [ ] Registration fails with weak password
- [ ] User profile appears in Firestore `users` collection
- [ ] After registration, redirects to main menu

### Existing User Login
- [ ] Can log in with correct credentials
- [ ] Login fails with incorrect password
- [ ] Login fails with non-existent email
- [ ] User session persists after app restart
- [ ] User profile loads correctly on login

### Sign Out
- [ ] Sign out button appears in main menu
- [ ] Clicking sign out returns to auth screen
- [ ] Can log back in after signing out

## 🎮 Gameplay Testing

### Basic Gameplay
- [ ] Can start Score Mode from menu
- [ ] Can start Time Mode from menu
- [ ] Can start Difficult Mode from menu
- [ ] 3-second peek phase works
- [ ] Cards flip on tap
- [ ] Matching cards stay revealed
- [ ] Non-matching cards flip back
- [ ] Turn counter increments correctly
- [ ] Timer counts down in time/difficult mode

### Game Completion
- [ ] Win condition triggers when all matches found
- [ ] Loss condition triggers when turns exceeded (Score Mode)
- [ ] Loss condition triggers when time runs out (Time/Difficult Mode)
- [ ] Score calculates correctly
- [ ] Bonus life awarded for perfect game (4 turns)

### Auto-Progression
- [ ] **Win screen shows 5-second countdown**
- [ ] **Countdown timer decreases each second**
- [ ] **Progress bar animates during countdown**
- [ ] **"Next Level Now" button works**
- [ ] **After 5 seconds, auto-advances to next level**
- [ ] **Can return to menu during countdown**
- [ ] **Loss screen shows 5-second countdown**
- [ ] **After 5 seconds on loss, auto-retries level**
- [ ] **"Retry Now" button works on loss screen**
- [ ] **No manual clicking needed between levels**

### Difficult Mode
- [ ] Grid size changes with level (3×3 → 4×4 → 5×5 → 6×6)
- [ ] Colors shuffle after each match
- [ ] Shuffle counter increments

## 🏆 Leaderboard Testing

### Score Saving
- [ ] Score saves to Firebase after game completion
- [ ] Score appears in Firestore `scores` collection
- [ ] Score includes userId, username, country, level, mode
- [ ] Timestamp is correct

### Global Leaderboard
- [ ] Can open global leaderboard from menu
- [ ] Shows top scores in descending order
- [ ] Displays username, score, level, mode
- [ ] Shows country flags
- [ ] Top 3 have medal badges (🥇🥈🥉)
- [ ] Refresh button updates leaderboard
- [ ] Empty state shows when no scores

### Regional Leaderboard
- [ ] Shows scores filtered by user's country
- [ ] Scores are in descending order
- [ ] Displays correct country flag for all entries
- [ ] Empty state shows when no regional scores

### Score History
- [ ] Shows user's personal score history
- [ ] Scores are in reverse chronological order
- [ ] Shows date and time for each score
- [ ] Shows mode icon and color
- [ ] Empty state shows when no personal scores

### Leaderboard UI
- [ ] Can switch between tabs (Global/Regional/My Scores)
- [ ] Time ago format works ("5m ago", "2h ago", "3d ago")
- [ ] Close button works
- [ ] Refresh button works

## 🎯 Achievement Testing

### Achievement Display
- [ ] Can open achievements from menu
- [ ] Shows all 10 achievements
- [ ] Progress bar shows unlock percentage
- [ ] Locked achievements appear grayed out
- [ ] Unlocked achievements have colored icons
- [ ] Achievement descriptions are clear
- [ ] Close button works

### Achievement Unlocking
Test each achievement:

- [ ] **First Victory**: Complete first level
  - Achievement unlocks
  - Syncs to Firebase
  - Appears in user's achievement list

- [ ] **Perfect Memory**: Complete level with 4 turns
  - Unlocks only when exactly 4 turns used
  - Works in Score Mode

- [ ] **Time Wizard**: Finish with 20+ seconds
  - Unlocks when time remaining ≥ 20
  - Works in Time/Difficult modes

- [ ] **Survivor**: Use bonus life and win
  - Unlocks when bonus life is used and level is won

- [ ] **Level Master**: Reach level 10
  - Unlocks when level 10 is reached
  - Syncs to Firebase

- [ ] **Marathon Runner**: Play 50 games
  - Check `gamesPlayed` increments in Firestore
  - Unlocks at 50 games

- [ ] **Score Hunter**: Get 10,000 total points
  - Check `totalScore` increments in Firestore
  - Unlocks at 10,000

Other achievements may require extended play testing.

## 👤 User Profile Testing

### Profile Display
- [ ] User profile shows in main menu
- [ ] Shows username correctly
- [ ] Shows country correctly
- [ ] Shows highest level reached
- [ ] Shows total score
- [ ] Updates after playing games

### Stats Tracking
- [ ] `gamesPlayed` increments after each game
- [ ] `totalScore` accumulates across games
- [ ] `highestLevel` updates when new level reached
- [ ] `lastPlayed` timestamp updates
- [ ] All changes sync to Firestore

## 🔄 Edge Cases & Error Handling

### Network Issues
- [ ] App handles no internet connection gracefully
- [ ] Shows error message when Firebase unavailable
- [ ] Local gameplay still works (if applicable)

### Multiple Devices
- [ ] Same user can log in on different devices
- [ ] Scores sync across devices
- [ ] Achievements sync across devices
- [ ] User profile syncs correctly

### Data Integrity
- [ ] Can't create duplicate scores
- [ ] Timestamps are accurate
- [ ] No data corruption in Firestore
- [ ] Security rules prevent unauthorized access

## 🎨 UI/UX Testing

### Main Menu
- [ ] User profile displays correctly
- [ ] All buttons are responsive
- [ ] Leaderboard button opens leaderboard
- [ ] Achievements button opens achievements
- [ ] Sign out button works
- [ ] Game mode buttons work
- [ ] Gradient background looks good

### Game Screen
- [ ] Cards display correctly in all grid sizes
- [ ] Animations are smooth
- [ ] Counters update in real-time
- [ ] Exit button works
- [ ] Win/loss overlays appear correctly

### Auto-Progression Overlays
- [ ] Win overlay shows score, stats, countdown
- [ ] Loss overlay shows appropriate message
- [ ] Countdown is clearly visible
- [ ] Progress bar animates smoothly
- [ ] Buttons are clickable during countdown
- [ ] Text is readable and centered

### Responsive Design
- [ ] Looks good on iPhone SE (small screen)
- [ ] Looks good on iPhone 15 Pro Max (large screen)
- [ ] Works in portrait orientation
- [ ] No UI elements cut off
- [ ] Text is readable on all screen sizes

## 📊 Performance Testing

- [ ] App launches quickly
- [ ] No lag when flipping cards
- [ ] Leaderboard loads in reasonable time
- [ ] No memory leaks during extended play
- [ ] Smooth transitions between screens
- [ ] Firebase queries complete quickly
- [ ] No crashes during normal use

## 🔒 Security Testing

- [ ] Can't access other users' data
- [ ] Can't modify other users' scores
- [ ] Can't unlock achievements without meeting requirements
- [ ] Email validation works
- [ ] Password requirements enforced
- [ ] Firestore security rules work correctly

## 📱 Platform Testing

Test on multiple devices/simulators:
- [ ] iPhone 15 Pro Max
- [ ] iPhone 14
- [ ] iPhone SE (3rd generation)
- [ ] iPad (if supporting)
- [ ] Different iOS versions (15.0, 16.0, 17.0)

## ✅ Final Checks

- [ ] All features work as expected
- [ ] No console errors or warnings
- [ ] Firebase costs are within expected range
- [ ] All documentation is up to date
- [ ] Screenshots taken for README
- [ ] App Store description prepared (if publishing)
- [ ] Privacy policy prepared (if required)
- [ ] Terms of service prepared (if required)

## 🚀 Pre-Release Checklist

Before submitting to App Store:
- [ ] Firebase security rules updated to production mode
- [ ] App Check enabled
- [ ] All test accounts removed
- [ ] Analytics configured (if using)
- [ ] Crash reporting enabled
- [ ] App icons added
- [ ] Launch screen configured
- [ ] Version number updated
- [ ] Build number incremented
- [ ] Code signing configured
- [ ] TestFlight build uploaded
- [ ] Beta testing completed

---

## 📝 Notes Section

Use this space to track issues found during testing:

### Issues Found:
1. 
2. 
3. 

### Issues Fixed:
1. 
2. 
3. 

### Known Limitations:
1. 
2. 
3. 

---

**Testing completed by:** _______________
**Date:** _______________
**iOS Version:** _______________
**Device:** _______________
