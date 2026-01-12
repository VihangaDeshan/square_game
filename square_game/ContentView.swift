import SwiftUI

// STEP 1: Define the Card structure
struct Card: Identifiable {
    let id = UUID()
    let colorIndex: Int
    var isFlipped: Bool = false
    var isMatched: Bool = false
    var isBonus: Bool = false
}

struct ContentView: View {
    // --- STATE VARIABLES ---
    @State private var cards: [Card] = []
    @State private var firstIndex: Int? = nil
    @State private var turns: Int = 0
    @State private var matchesFound: Int = 0
    @State private var size: Int = 4 // Default
    @State private var gameID = UUID() // Prevents the crash
    @State private var isBusy: Bool = false
    @State private var winMessage: String = ""

    let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan, .mint, .indigo, .teal, .brown]

    var body: some View {
        VStack {
            // STEP 2: Header showing Score and Turns
            gameHeader
            
            // STEP 3: The Game Grid
            if cards.isEmpty {
                menuView
            } else {
                gameGridView
                    .id(gameID) // Forces a fresh draw to avoid "Index out of range"
                
                if !winMessage.isEmpty {
                    winOverlay
                }
                
                Button("Exit to Menu") { cards = [] }
                    .padding().foregroundColor(.red)
            }
        }
    }

    // --- UI SUB-VIEWS ---

    var menuView: some View {
        VStack(spacing: 20) {
            Text("Memory Match").font(.largeTitle).bold()
            Button("Easy (3x3)") { setupGame(3) }
            Button("Medium (5x5)") { setupGame(5) }
            Button("Hard (7x7)") { setupGame(7) }
        }.buttonStyle(.borderedProminent)
    }

    var gameHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Turns: \(turns)").font(.headline)
                Text("Min Turns Needed: \( (size * size) / 2 )").font(.caption)
            }
            Spacer()
            Text("Score: \(calculateScore())").font(.title2).bold()
        }.padding()
    }

    var gameGridView: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: size)
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, color: card.colorIndex == -1 ? .clear : colors[card.colorIndex % colors.count])
                    .onTapGesture {
                        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                            handleTap(at: idx)
                        }
                    }
            }
        }.padding()
    }

    var winOverlay: some View {
        VStack {
            Text(winMessage)
                .font(.largeTitle).bold()
                .foregroundColor(winMessage.contains("GREAT") ? .green : .blue)
            Text("Final Score: \(calculateScore())")
        }.padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
    }

    // --- GAME LOGIC ---

    func setupGame(_ newSize: Int) {
        size = newSize
        turns = 0
        matchesFound = 0
        firstIndex = nil
        winMessage = ""
        
        let total = size * size
        let pairCount = total / 2
        var newCards: [Card] = []

        for i in 0..<pairCount {
            newCards.append(Card(colorIndex: i))
            newCards.append(Card(colorIndex: i))
        }
        newCards.shuffle()

        // Handle the middle square for odd grids (3x3, 5x5, 7x7)
        if total % 2 != 0 {
            newCards.insert(Card(colorIndex: -1, isFlipped: true, isMatched: true, isBonus: true), at: total / 2)
        }
        
        cards = newCards
        gameID = UUID() // Refresh the view identity
    }

    func handleTap(at index: Int) {
        guard !isBusy, !cards[index].isFlipped, !cards[index].isMatched else { return }

        withAnimation { cards[index].isFlipped = true }

        if let second = firstIndex {
            turns += 1
            checkForMatch(idx1: second, idx2: index)
        } else {
            firstIndex = index
        }
    }

    func checkForMatch(idx1: Int, idx2: Int) {
        if cards[idx1].colorIndex == cards[idx2].colorIndex {
            matchesFound += 1
            firstIndex = nil
            checkWin()
        } else {
            isBusy = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    cards[idx1].isFlipped = false
                    cards[idx2].isFlipped = false
                }
                firstIndex = nil
                isBusy = false
            }
        }
    }

    func calculateScore() -> Int {
        let minTurns = (size * size) / 2
        let penalty = max(0, (turns - minTurns) * 10)
        return (matchesFound * 20) - penalty
    }

    func checkWin() {
        let totalPairs = (size * size) / 2
        if matchesFound == totalPairs {
            let minTurns = totalPairs
            if turns == minTurns {
                winMessage = "⭐ GREAT WIN! ⭐"
            } else {
                winMessage = "General Win"
            }
        }
    }
}

// Separate UI component for the Card
struct CardView: View {
    let card: Card
    let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(card.isFlipped || card.isMatched ? color : Color.gray)
            if !card.isFlipped && !card.isMatched {
                Text("?").foregroundColor(.white)
            } else if card.isBonus {
                Text("🌟")
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(card.isMatched && !card.isBonus ? 0.3 : 1)
    }
}
