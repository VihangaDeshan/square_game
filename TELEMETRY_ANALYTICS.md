# 📊 Telemetry & Analytics System

## Overview
The app now includes a comprehensive, privacy-focused telemetry system that tracks user behavior and gameplay metrics **only with explicit user consent**.

---

## 🔐 Privacy-First Design

### User Consent Required
- **No tracking without permission**: Analytics are disabled by default
- **Granular control**: Users choose exactly what data to share
- **Transparent collection**: Clear descriptions of what's collected
- **Easy to revoke**: Settings can be changed anytime
- **GDPR/CCPA compliant**: Meets privacy regulations

---

## ✅ What's Tracked (With Consent)

### 1. **Gameplay Tracking** 🎮
When enabled, tracks:
- **Game Sessions**: Start time, end time, duration
- **Level Progress**: Level completed, score, turns used, time remaining
- **Perfect Games**: Whether player achieved perfect score (4 turns)
- **Game Modes**: Score, Time, or Difficult mode
- **Level Failures**: Which levels failed and why (timeout, too many turns)

**Example Data**:
```
Event: level_complete
- level: 5
- mode: score
- score: 850
- turns: 6
- time_remaining: 0
- duration_seconds: 45
- is_perfect: false
```

### 2. **Performance Tracking** ⚡
When enabled, tracks:
- **Load Times**: How long screens take to load
- **Memory Usage**: Memory warnings and usage patterns
- **App Performance**: Frame rates, response times
- **Performance Metrics**: Custom performance measurements

**Use Case**: Helps identify slow screens or memory leaks

### 3. **Crash Reporting** 🐛
When enabled, tracks:
- **Errors**: Error messages and descriptions
- **Context**: Where in the app the error occurred
- **Error Frequency**: How often specific errors happen

**Use Case**: Helps fix bugs faster

### 4. **Usage Statistics** 📈
When enabled, tracks:
- **Session Duration**: How long users play
- **Feature Usage**: Which menu items clicked
- **Screen Views**: Which screens visited
- **Navigation Patterns**: How users move through the app

**Example Data**:
```
Event: feature_used
- feature: view_leaderboard
- timestamp: 2026-01-30T10:30:00Z
```

### 5. **Personalization** 👤
When enabled, tracks:
- **User ID**: Firebase authentication ID
- **Country**: Selected country for leaderboards
- **Highest Level**: Progress tracking
- **Total Score**: Cumulative score
- **Achievements**: Which achievements unlocked

**Use Case**: Enables personalized experience and leaderboard features

---

## 🎯 Consent Flow

### First Launch
1. User creates account or signs in
2. **Consent screen appears automatically**
3. User sees 5 permission categories with detailed explanations
4. User can:
   - ✅ Accept All (one-tap enable all)
   - ✅ Select individual permissions
   - ✅ Decline All and continue
5. App remembers choice permanently

### Changing Preferences
1. Main Menu → **Privacy & Data** button
2. Same consent screen opens
3. Toggle permissions on/off
4. Changes take effect immediately

---

## 📱 Consent Screen Features

### Permission Categories

#### 1. Gameplay Tracking
- **Icon**: 🎮 Game controller
- **Color**: Blue
- **Details**: Shows examples like "Play time, Scores and levels, Achievements unlocked"

#### 2. Performance Tracking
- **Icon**: ⚡ Speedometer
- **Color**: Orange
- **Details**: "Load times, Memory usage, Frame rates, Response times"

#### 3. Crash Reporting
- **Icon**: ⚠️ Warning triangle
- **Color**: Red
- **Details**: "Crash logs, Error messages, Device information, App version"

#### 4. Usage Statistics
- **Icon**: 📊 Bar chart
- **Color**: Green
- **Details**: "Feature usage, Session duration, Navigation patterns, Button clicks"

#### 5. Personalization
- **Icon**: 👤 Person
- **Color**: Purple
- **Details**: "User ID, Country preference, Game settings, Leaderboard position"

### Expandable Details
Each permission has a "Show Details" button that expands to show exactly what's collected.

---

## 🔍 Data Storage

### Firestore Collection: `analytics_events`
All analytics events stored with:
- **event_name**: Type of event (login, level_complete, etc.)
- **timestamp**: When event occurred
- **Event-specific fields**: score, level, duration, etc.

### Automatic Retention
- Events automatically deleted after **14 months**
- Users can request immediate deletion
- No third-party sharing

### Data Security
- ✅ Encrypted in transit (HTTPS)
- ✅ Encrypted at rest (Firebase encryption)
- ✅ Access controlled by Firebase Security Rules
- ✅ Only accessible by authenticated app developers

---

## 📊 Events Tracked

### Authentication Events
| Event | Triggered When | Data Collected |
|-------|---------------|----------------|
| `login` | User signs in | method, user_id (if allowed) |
| `sign_up` | New account created | method, user_id (if allowed) |
| `logout` | User signs out | timestamp |

### Gameplay Events
| Event | Triggered When | Data Collected |
|-------|---------------|----------------|
| `game_start` | New game begins | level, mode |
| `level_complete` | Level won | level, mode, score, turns, time_remaining, duration, is_perfect |
| `level_failed` | Level lost | level, mode, score, duration, failure_reason |
| `game_end` | Game session ends | total_score, highest_level, total_play_time |
| `high_score` | New high score | score, level, mode |
| `achievement_unlocked` | Achievement earned | achievement_id, achievement_name |

### UI Events
| Event | Triggered When | Data Collected |
|-------|---------------|----------------|
| `screen_view` | Screen opened | screen_name, screen_class |
| `feature_used` | Feature accessed | feature_name, context |
| `session_start` | App opened | timestamp |
| `session_end` | App closed | duration_seconds |

### Error Events
| Event | Triggered When | Data Collected |
|-------|---------------|----------------|
| `error_occurred` | Error happens | error_description, context |
| `memory_warning` | Low memory | timestamp |
| `performance_metric` | Performance measured | metric, value, context |

---

## 🛠️ Technical Implementation

### AnalyticsManager (Singleton)
```swift
@StateObject private var analyticsManager = AnalyticsManager.shared
```

#### Key Methods:
- `startSession()` - Track app launch
- `endSession()` - Track app close
- `trackLogin()` - User authentication
- `trackGameStart()` - Game begins
- `trackLevelComplete()` - Level won
- `trackFeatureUsed()` - Feature clicked
- `trackError()` - Error occurred

### Consent Checking
Every tracking call checks consent first:
```swift
guard consent.allowGameplayTracking else { return }
```

### Firestore Integration
Events logged to `analytics_events` collection:
```swift
db.collection("analytics_events").addDocument(data: eventData)
```

---

## 🎮 User Experience

### Minimal Disruption
- ✅ Consent shown only once on first launch
- ✅ Can decline all and still use app fully
- ✅ No nag screens or pop-ups
- ✅ Settings easily accessible anytime

### Clear Communication
- ✅ Plain language explanations
- ✅ Specific examples of data collected
- ✅ Visual categorization with icons/colors
- ✅ Expandable details for transparency

### VoiceOver Support
- ✅ All toggles properly labeled
- ✅ State announced ("enabled"/"disabled")
- ✅ Descriptions read aloud
- ✅ Full keyboard navigation

---

## 📈 Analytics Dashboard (Future)

Developers can view (sample queries):

### Popular Game Modes
```
SELECT mode, COUNT(*) 
FROM analytics_events 
WHERE event_name = 'game_start'
GROUP BY mode
```

### Average Session Duration
```
SELECT AVG(duration_seconds) 
FROM analytics_events 
WHERE event_name = 'session_end'
```

### Most Failed Levels
```
SELECT level, COUNT(*) 
FROM analytics_events 
WHERE event_name = 'level_failed'
GROUP BY level
ORDER BY COUNT(*) DESC
```

### Achievement Unlock Rates
```
SELECT achievement_name, COUNT(DISTINCT user_id) 
FROM analytics_events 
WHERE event_name = 'achievement_unlocked'
GROUP BY achievement_name
```

---

## 🔒 Security & Compliance

### Firebase Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /analytics_events/{event} {
      // Only app can write analytics
      allow write: if request.auth != null;
      // Only admins can read
      allow read: if false;
    }
  }
}
```

### GDPR Compliance
- ✅ **Right to be informed**: Clear consent screen
- ✅ **Right to access**: Users can request their data
- ✅ **Right to erasure**: Can revoke consent
- ✅ **Right to restrict processing**: Granular permissions
- ✅ **Data minimization**: Only collect what's needed
- ✅ **Purpose limitation**: Data only for stated purposes

### CCPA Compliance
- ✅ **Notice at collection**: Consent screen explains everything
- ✅ **Opt-out mechanism**: Decline All button
- ✅ **Do not sell**: Data never sold or shared

---

## 🎯 Best Practices

### For Developers
1. **Respect consent always**: Never bypass checks
2. **Minimize data**: Only collect what's truly useful
3. **Regular audits**: Review what's being tracked
4. **Secure storage**: Use Firebase Security Rules
5. **Anonymous by default**: Only track user ID if allowed

### For Users
1. **Review permissions**: Understand what you're sharing
2. **Start minimal**: Enable only essential tracking
3. **Update as needed**: Change settings anytime
4. **Check Privacy Details**: Read the expanded information
5. **Ask questions**: Contact support for clarifications

---

## 📲 How to Access

### Consent Screen
- **First Launch**: Appears automatically after sign-in
- **Anytime**: Main Menu → **Privacy & Data** button (indigo)

### View Current Settings
1. Main Menu
2. Tap "Privacy & Data"
3. See all permissions with current states
4. Toggle any on/off
5. Tap "Save & Continue"

---

## 🎉 Benefits

### For Players
- ✅ **Full control** over data sharing
- ✅ **Transparency** about what's collected
- ✅ **No ads** or third-party tracking
- ✅ **Better app** through informed improvements

### For Developers
- ✅ **Understand usage** patterns
- ✅ **Identify bugs** faster
- ✅ **Optimize performance**
- ✅ **Make data-driven** decisions
- ✅ **Improve features** players love

---

## 📝 Summary

The Memory Color Match game now includes a **comprehensive, privacy-focused analytics system** that:

1. ✅ **Requires explicit consent** before any tracking
2. ✅ **Offers granular control** with 5 permission categories
3. ✅ **Stores data securely** in Firebase Firestore
4. ✅ **Respects user privacy** with no third-party sharing
5. ✅ **Complies with regulations** (GDPR, CCPA)
6. ✅ **Improves the game** through data-driven insights
7. ✅ **Can be changed anytime** in Privacy Settings

**Privacy first. Always.** 🔐
