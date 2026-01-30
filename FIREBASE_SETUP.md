# Firebase Setup Instructions for Memory Color Match Game

## Overview
This guide will help you integrate Firebase into your Memory Color Match game to enable:
- User authentication (Email/Password)
- Global and regional leaderboards
- Player score history tracking
- Achievement system

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Enter project name (e.g., "MemoryColorMatch")
4. Enable/disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add iOS App to Firebase Project

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter your iOS bundle identifier (found in Xcode project settings)
   - Example: `com.yourname.square-game`
3. Enter app nickname (optional): "Memory Color Match"
4. Enter App Store ID (optional, can be added later)
5. Click "Register app"

## Step 3: Download GoogleService-Info.plist

1. Download the `GoogleService-Info.plist` file
2. In Xcode, right-click on the `square_game` folder
3. Select "Add Files to square_game"
4. Select the downloaded `GoogleService-Info.plist` file
5. **IMPORTANT**: Make sure "Copy items if needed" is checked
6. Make sure the file is added to the `square_game` target
7. Click "Add"

## Step 4: Add Firebase SDK Dependencies

### Using Swift Package Manager (Recommended):

1. In Xcode, go to File → Add Package Dependencies
2. Enter the Firebase repository URL:
   ```
   https://github.com/firebase/firebase-ios-sdk.git
   ```
3. Select version: 10.0.0 or later
4. Click "Add Package"
5. Select the following packages:
   - **FirebaseAuth** (for authentication)
   - **FirebaseFirestore** (for database)
   - **FirebaseCore** (required)
6. Click "Add Package"

## Step 5: Enable Authentication in Firebase

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Click "Save"

## Step 6: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (for development)
   - For production, use production mode with proper security rules
4. Choose a Cloud Firestore location (closest to your users)
5. Click "Enable"

### Recommended Security Rules (for production):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Scores collection - authenticated users can read all, write their own
    match /scores/{scoreId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## Step 7: Create Database Indexes

To optimize leaderboard queries, create the following indexes in Firestore:

1. Go to **Firestore Database** → **Indexes** tab
2. Click "Create index"

### Index 1: Global Leaderboard
- Collection ID: `scores`
- Fields to index:
  - `score` (Descending)
  - `timestamp` (Descending)
- Query scope: Collection

### Index 2: Regional Leaderboard
- Collection ID: `scores`
- Fields to index:
  - `country` (Ascending)
  - `score` (Descending)
  - `timestamp` (Descending)
- Query scope: Collection

### Index 3: User Score History
- Collection ID: `scores`
- Fields to index:
  - `userId` (Ascending)
  - `timestamp` (Descending)
- Query scope: Collection

## Step 8: Update Info.plist (if needed)

If you encounter any network issues, add the following to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Step 9: Build and Run

1. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
2. Build the project: Product → Build (Cmd+B)
3. Run on simulator or device: Product → Run (Cmd+R)

## Firestore Database Structure

### Users Collection (`users`)
```json
{
  "userId": {
    "id": "string",
    "username": "string",
    "email": "string",
    "country": "string",
    "totalScore": "number",
    "gamesPlayed": "number",
    "highestLevel": "number",
    "achievements": ["array of achievement IDs"],
    "createdAt": "timestamp",
    "lastPlayed": "timestamp"
  }
}
```

### Scores Collection (`scores`)
```json
{
  "scoreId": {
    "id": "string",
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

## Features Implemented

### 1. **User Authentication**
- New users are prompted to register on first launch
- Existing users can log in with email/password
- User session persists across app launches

### 2. **Leaderboards**
- **Global Leaderboard**: Top 100 scores worldwide
- **Regional Leaderboard**: Top 100 scores by country
- **Score History**: Personal score history (last 100 games)

### 3. **Achievements System**
The game tracks 10 achievements:
- **First Victory**: Complete your first level
- **Perfect Memory**: Complete a level with 4 turns
- **Speedster**: Complete 5 time mode levels
- **Marathon Runner**: Play 50 games
- **Level Master**: Reach level 10
- **Score Hunter**: Accumulate 10,000 total points
- **Match Maker**: Find 500 matches
- **Survivor**: Use a bonus life and win
- **Difficult Champion**: Complete 10 difficult mode levels
- **Time Wizard**: Finish with 20+ seconds remaining

### 4. **Auto-Progression**
- After winning: Automatically advances to next level after 5 seconds
- After losing: Automatically retries the level after 5 seconds
- Players can skip the countdown and proceed immediately
- Countdown timer with progress bar is displayed

### 5. **Continuous Gameplay**
- No interruptions between levels
- Scores automatically saved to Firebase
- Achievements unlocked in real-time

## Testing

1. **Create test accounts**: Register 2-3 test users
2. **Play games**: Complete levels in different modes
3. **Check leaderboards**: Verify scores appear correctly
4. **Test achievements**: Try to unlock different achievements
5. **Test auto-progression**: Let countdown complete and verify navigation

## Troubleshooting

### Issue: App crashes on launch
- Verify `GoogleService-Info.plist` is in the project
- Check that Firebase packages are properly installed
- Clean and rebuild the project

### Issue: Authentication not working
- Verify Email/Password is enabled in Firebase Console
- Check internet connection
- Review Firebase Console logs

### Issue: Scores not appearing in leaderboard
- Verify Firestore database is created
- Check security rules allow read/write
- Create necessary indexes
- Check Firebase Console for data

### Issue: Auto-progression not working
- Check that GameViewModel timer is running
- Verify countdown state is updating
- Check console for any errors

## Next Steps

1. **Customize countries list**: Edit the countries array in `AuthenticationView.swift`
2. **Add more achievements**: Extend the achievements in `FirebaseManager.swift`
3. **Implement push notifications**: For achievement unlocks and weekly leaderboard updates
4. **Add social features**: Friend system, challenges, etc.
5. **Analytics**: Track user behavior with Firebase Analytics

## Support

For Firebase-specific issues, refer to:
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth/ios/start)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

## Security Notes

⚠️ **IMPORTANT**: Before publishing to App Store:
1. Update Firestore security rules to production mode
2. Enable App Check for additional security
3. Set up proper user data privacy policies
4. Review and secure all Firebase settings
5. Never commit `GoogleService-Info.plist` to public repositories

---

**Congratulations!** Your Memory Color Match game now has full Firebase integration with authentication, leaderboards, and achievements! 🎉
