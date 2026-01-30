# Firebase Analytics Debug Mode Setup

## Issue
Firebase Analytics DebugView shows "Waiting for debug events" because:
1. FirebaseAnalytics package not explicitly added to project
2. Debug mode not enabled on simulator/device

## Solution

### Step 1: Add FirebaseAnalytics Package

1. Open `square_game.xcodeproj` in Xcode
2. Select the project in the Project Navigator
3. Select the **square_game** target
4. Click the **General** tab
5. Scroll to **Frameworks, Libraries, and Embedded Content**
6. Click the **+** button
7. Search for `FirebaseAnalytics`
8. Select **FirebaseAnalytics** from the list
9. Click **Add**

Alternatively, use the Package Dependencies method:
1. Select the project (not target)
2. Go to **Package Dependencies** tab
3. The Firebase package is already there (12.8.0)
4. In the target's **General** tab → **Frameworks, Libraries, and Embedded Content**
5. Click **+** → **Add Other...** → **Add Package Product...**
6. Select **FirebaseAnalytics** from the dropdown
7. Click **Add**

### Step 2: Enable Debug Mode

#### For iOS Simulator:
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Arguments Passed On Launch**, click the **+** button
5. Add: `-FIRDebugEnabled`
6. Click **Close**

#### For Physical Device:
Same as simulator - add the launch argument in the scheme.

### Step 3: Verify Setup

1. **Build and run** the app with the new scheme
2. In Xcode console, you should see:
   ```
   📊 Firebase Analytics collection: true
   📊 Logged to Firebase Analytics: user_login
   ```
3. When you trigger an event (login, start game, etc.), check Firebase console
4. Go to **Analytics** → **DebugView**
5. Select your device from the dropdown (should show as "debugger")
6. Events should appear in real-time

### Step 4: Test Analytics

Trigger these events in order:
1. **Sign in** → Should log `user_login` event
2. **Start a game** → Should log `game_start` event  
3. **Complete a level** → Should log `level_complete` event with parameters:
   - level_number
   - score
   - turns_taken
   - duration_seconds
   - is_perfect

### Debugging Tips

**Check Console Output:**
```bash
# Look for these messages:
📊 Firebase Analytics collection: enabled
📊 Logged to Firebase Analytics: [event_name]
```

**If events still don't appear:**
1. Make sure you accepted analytics consent in the app
2. Verify `-FIRDebugEnabled` launch argument is set
3. Check that device/simulator appears in DebugView dropdown
4. Wait 5-10 seconds after triggering an event
5. Restart the simulator and try again

**Verify Package Import:**
The code now uses conditional compilation:
```swift
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
```

If the package isn't added, events will still log to Firestore but not to Analytics dashboard.

## Current Analytics Events

### Authentication Events
- `user_signup` - When user creates account
- `user_login` - When user signs in  
- `user_logout` - When user signs out
- `authentication_error` - Failed auth attempts

### Gameplay Events
- `game_start` - Game begins (level, mode, difficulty)
- `level_complete` - Level finished successfully (score, turns, duration, perfect)
- `level_failed` - Level failed (attempts, reason)
- `game_pause` - Game paused
- `game_resume` - Game resumed

### Feature Usage Events  
- `screen_view` - Screen displayed (screen_name)
- `feature_used` - Feature accessed (feature_name)
- `achievement_unlocked` - Achievement earned (achievement_id)
- `settings_changed` - Settings modified (setting_name, value)

### Performance Events
- `session_start` - App session begins
- `session_end` - App session ends (duration)
- `error_occurred` - App error (error_code, description)

## Privacy Compliance

Analytics respect user consent with 5 categories:
1. **Gameplay Analytics** - Track game progress and performance
2. **Performance Monitoring** - App speed and responsiveness  
3. **Crash Reporting** - Error tracking and diagnostics
4. **Usage Statistics** - Feature usage patterns
5. **Personalization** - Preferences and customization

Users can enable/disable each category individually from **Privacy & Data** menu.

## Next Steps

1. ✅ Code updated with Firebase Analytics SDK integration
2. ⏳ Add FirebaseAnalytics package in Xcode (Step 1 above)
3. ⏳ Enable debug mode with launch argument (Step 2 above)
4. ⏳ Test event flow (Step 4 above)
5. ⏳ Verify events appear in DebugView

Once setup is complete, events should appear in Firebase Analytics DebugView in real-time!
