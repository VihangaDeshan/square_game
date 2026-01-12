# Memory Match Game

A fun and engaging memory matching game built with SwiftUI for iOS.

## Description

Memory Match is a classic card-matching game where players flip cards to find matching pairs. The game features different difficulty levels and tracks your performance with a scoring system.

## Features

- **Three Difficulty Levels:**
  - Easy (3x3 grid)
  - Medium (5x5 grid)
  - Hard (7x7 grid)

- **Scoring System:**
  - Earn 20 points for each match
  - Penalty of 10 points for each turn over the minimum required

- **Visual Feedback:**
  - Cards flip with smooth animations
  - Matched cards fade out
  - Bonus star card for odd-sized grids
  - Special "Great Win" message for perfect games

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** architecture pattern for clean code organization:

### Structure

```
square_game/
├── Models/
│   └── Card.swift              # Card data model
├── Views/
│   └── CardView.swift          # Card UI component
├── ViewModels/
│   └── GameViewModel.swift     # Game logic and state management
├── ContentView.swift           # Main game view
└── square_gameApp.swift        # App entry point
```

### Components

- **Model (Card.swift):** Defines the Card structure with properties like color, flip state, and match state.

- **View (CardView.swift):** Reusable UI component that displays individual cards with appropriate styling.

- **ViewModel (GameViewModel.swift):** Manages all game logic including:
  - Card setup and shuffling
  - Turn counting
  - Match checking
  - Score calculation
  - Win condition detection

- **ContentView:** Main view that presents the game UI using the ViewModel.

## How to Play

1. **Start the Game:** Choose a difficulty level from the main menu
2. **Flip Cards:** Tap on cards to flip them over
3. **Find Matches:** Try to remember card positions and match pairs
4. **Win:** Match all pairs in the minimum number of turns for a perfect score!

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

1. Clone this repository
2. Open `square_game.xcodeproj` in Xcode
3. Build and run on your iOS device or simulator

## Game Rules

- The game tracks the number of turns (one turn = flipping two cards)
- Minimum turns needed = (grid size × grid size) / 2
- Achieving the minimum turns earns a "GREAT WIN!" message
- Each turn over the minimum reduces your score by 10 points
- Each successful match adds 20 points to your score

## Code Quality

The codebase follows Swift best practices:
- ✅ Separation of concerns (MVVM pattern)
- ✅ Proper documentation and comments
- ✅ SwiftUI declarative syntax
- ✅ Reactive state management with `@Published` properties
- ✅ Clean and readable code structure

## Future Enhancements

Potential features for future versions:
- High score persistence
- Sound effects and haptic feedback
- Custom themes and card designs
- Multiplayer mode
- Timer-based challenges
- Leaderboards

## License

This project is open source and available for educational purposes.

## Author

Created by COBSCCOMP24.2P-008
