# Memory Color Match - Complete Features

## 🎮 New Level Progression System

### Score Mode (Levels 1-7)
All levels use **3×3 grid** with center bonus square (🌟)

| Level | Max Moves | Pass Condition |
|-------|-----------|----------------|
| 1 | 10 | Complete within 10 moves or less |
| 2 | 9 | Complete within 9 moves or less |
| 3 | 8 | Complete within 8 moves or less |
| 4 | 7 | Complete within 7 moves or less |
| 5 | 6 | Complete within 6 moves or less |
| 6 | 5 | Complete within 5 moves or less |
| 7 | 4 | Complete within 4 moves (Perfect!) |

### Time Mode (Level 8+)
- Same 3×3 grid with center bonus square
- 30 seconds time limit per level
- Must find all matches before time runs out

## ⭐ Bonus Life System

### Starting Lives
- Each level begins with **1 bonus life** (🌟)

### Earning Extra Lives
- **Perfect Game**: Complete any level with exactly **4 moves** = +1 bonus life
- Bonus lives carry over to next level

### Using Lives
When you run out of turns/time:
- **Score Mode**: Automatically grants **2 extra turns**
- **Time Mode**: Automatically grants **10 extra seconds**
- Life is consumed after use

## 🎯 Win/Fail Conditions

### Score Mode
- ✅ **WIN**: Find all 4 pairs within max moves
- ❌ **FAIL**: Exceed max moves for that level
- Example: Level 1 allows 10 moves. If you use 11 moves = FAIL

### Time Mode
- ✅ **WIN**: Find all 4 pairs within 30 seconds
- ❌ **FAIL**: Time runs out before all pairs found

## 👁️ Peeking Feature
- **Every level** starts with a 3-second peek
- All cards flip face-up to show colors
- After 3 seconds, cards flip back and game begins
- Use this time to memorize positions!

## 📊 Scoring System

### Base Points
- **100 points** per match found
- Multiplied by level number

### Bonuses
**Score Mode:**
- Perfect game (4 moves): **+200 points**
- Each unused turn: **+20 points**

**Time Mode:**
- Each remaining second: **+10 points**

### Formula
```
Total Score = (Matches × 100) + Bonuses + (Level × 50)
```

## 🎨 UI Features

### Game Header
- Current level and mode
- Bonus lives (🌟)
- Matches found (X/4)
- Turns/Time remaining (color-coded)
- Current score

### Color Coding
**Turns Remaining:**
- 🟢 Green: 3+ turns left
- 🟠 Orange: 2 turns left
- 🔴 Red: 1 turn left

**Time Remaining:**
- 🟢 Green: 11+ seconds
- 🟠 Orange: 6-10 seconds
- 🔴 Red: 5 seconds or less

### Win Overlay
- Shows if perfect game achieved
- Displays final score and stats
- Options: Next Level or Menu
- Prompts for name if high score

### Fail Overlay
- Shows reason for failure
- Displays turns/time exceeded
- Options: Retry or Menu

## 🏆 High Scores

### Saving
- Automatically saves top 10 scores
- Prompts for player name if high score achieved
- Remembers last player name used

### Storage
- Persisted using UserDefaults
- Survives app restarts
- Can view from main menu

## 📱 Main Menu Options

1. **Start Game** - Begin at Level 1 (Score Mode)
2. **Select Mode**
   - Score Mode: Start at Level 1
   - Time Mode: Jump to Level 8
3. **High Scores** - View top 10 players
4. **How to Play** - Complete game rules

## 🎯 Perfect Game Strategy

To achieve 4 moves (minimum possible):
1. Memorize all positions during 3-second peek
2. Match all 4 pairs without mistakes
3. Each successful match = 1 move
4. 4 pairs × 1 move = 4 total moves = PERFECT! ⭐

## 🔄 Game Flow

```
Main Menu
    ↓
Level Starts
    ↓
3-Second Peek (all cards visible)
    ↓
Cards Flip Back
    ↓
Player Makes Moves
    ↓
    ├─→ All Matched Within Limit → WIN → Next Level
    │                                ↓
    │                           Check Perfect (4 moves?)
    │                                ↓
    │                           Award Bonus Life if perfect
    │
    └─→ Exceed Limit → Use Bonus Life OR FAIL
                            ↓
                       Retry or Menu
```

## 🚀 Technical Implementation

### Architecture
- **MVVM Pattern**
- GameModel.swift - Data structures
- GameViewModel.swift - Business logic
- GameView.swift - UI rendering
- HighScoreManager.swift - Persistence

### Animations
- 3D card flip using `.rotation3DEffect`
- Spring animations for smooth transitions
- Matched cards fade and scale down

### State Management
- @StateObject for ViewModels
- @Published properties for UI updates
- Combine framework for timer

## 🎮 How to Play

1. Tap **Start Game** from menu
2. Watch 3-second peek - memorize colors!
3. Tap two cards to flip them
4. If colors match, they stay visible
5. If not, they flip back
6. Find all 4 pairs within move/time limit
7. Earn bonus life for perfect games (4 moves)
8. Progress through levels 1-7, then time mode
9. Save your high score!

---

**Enjoy the challenge!** 🧠💪
