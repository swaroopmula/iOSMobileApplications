import SwiftUI

struct NumTacShiftGame: View {
    @Environment(\.dismiss) private var dismiss
    
    // Game state
    @State private var board: [[Int?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    @State private var timestamps: [[Date?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    @State private var isPlayer1Turn = true
    @State private var showVictory = false
    @State private var winner: Int? = nil
    @State private var showInfo = false
    
    // Add these properties
    @State private var activeCell: (row: Int, col: Int)? = nil
    private let gridSpacing: CGFloat = 8
    private let cellLifetime: TimeInterval = 3.0
    private let cellSize: CGFloat = 90  // Increased size
    
    // Add this property to track empty cell timers
    @State private var emptyCellTimers: [[Date?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    
    // Add these new properties
    @State private var nextDisappearTime: Date? = nil
    @State private var lastDisappearedCell: (row: Int, col: Int)? = nil
    
    // Add these properties for dynamic timing
    @State private var gameStartTime: Date? = nil
    private let initialCellLifetime: TimeInterval = 3.0
    private let speedupInterval: TimeInterval = 10.0  // Time between speed changes
    private let speedupLevels: [TimeInterval] = [3.0, 2.0, 1.0]  // Different speed levels
    
    // Remove time-related properties and add turn counter
    @State private var turnCount = 0
    @State private var movesLifespan: [[Int?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    private let maxTurns = 6  // Changed from 5 to 6
    
    // Add this computed property to calculate current cell lifetime
    private var currentCellLifetime: TimeInterval {
        return 3.0
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                GameHeader(
                    title: "NumTac Shift",
                    onDismiss: { dismiss() },
                    onInfo: { showInfo = true }
                )
                
                ScrollView {
                    gameContent
                }
            }
            
            // Overlays
            if showVictory {
                VictoryOverlay(
                    attempts: turnCount,
                    winnerNumber: winner,
                    onRestart: {
                        showVictory = false
                        resetGame()
                    },
                    onClose: { dismiss() }
                )
            }
            
            if showInfo {
                InfoOverlay(
                    gameType: .numTacShift,
                    onClose: { showInfo = false }
                )
            }
        }
        .onAppear {
            resetGame()
        }
        // Remove .onReceive(timer) and replace with just win condition check
        .onChange(of: board) { _ in
            checkWinCondition()
        }
    }
    
    // Break down the content into smaller views
    private var gameContent: some View {
        VStack(spacing: 24) {
            playerStatusView
            gameGridView
        }
    }
    
    private var playerStatusView: some View {
        HStack(spacing: 40) {
            PlayerCard(
                number: 1,
                isActive: isPlayer1Turn,
                symbol: ""
            )
            
            PlayerCard(
                number: 0,
                isActive: !isPlayer1Turn,
                symbol: ""
            )
        }
        .padding(.top, 20)
    }
    
    private var gameGridView: some View {
        VStack(spacing: 2) {  // Reduced spacing for grid look
            ForEach(0..<3) { row in
                HStack(spacing: 2) {  // Reduced spacing for grid look
                    ForEach(0..<3) { col in
                        createGridCell(row: row, col: col)
                    }
                }
            }
        }
        .padding(2)  // Added small padding for outer border
        .background(Theme.secondary.opacity(0.3))  // Added background for grid
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func createGridCell(row: Int, col: Int) -> some View {
        GridCell(
            number: board[row][col],
            moveTime: movesLifespan[row][col],
            currentTurn: turnCount,
            maxTurns: maxTurns,
            isActive: activeCell?.row == row && activeCell?.col == col,
            onTap: {
                if canMakeMove(row: row, col: col) {
                    withAnimation {
                        activeCell = (row, col)
                    }
                    makeMove(row: row, col: col)
                }
            }
        )
        .frame(width: cellSize, height: cellSize)
    }
    
    private func makeMove(row: Int, col: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            board[row][col] = isPlayer1Turn ? 1 : 0
            movesLifespan[row][col] = turnCount  // Record when the move was made
            isPlayer1Turn.toggle()
            turnCount += 1
            
            // Check for moves that need to be removed
            checkExpiredMoves()
        }
    }
    
    private func checkExpiredMoves() {
        for row in 0..<3 {
            for col in 0..<3 {
                if let moveTime = movesLifespan[row][col] {
                    if turnCount - moveTime >= maxTurns {
                        withAnimation(.easeOut(duration: 0.3)) {
                            board[row][col] = nil
                            movesLifespan[row][col] = nil
                            lastDisappearedCell = (row, col)
                            
                            // Clear lastDisappearedCell after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                lastDisappearedCell = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkWinCondition() {
        // Check rows
        for row in 0..<3 {
            if let first = board[row][0],
               board[row][1] == first,
               board[row][2] == first {
                winner = first
                showVictory = true
                return
            }
        }
        
        // Check columns
        for col in 0..<3 {
            if let first = board[0][col],
               board[1][col] == first,
               board[2][col] == first {
                winner = first
                showVictory = true
                return
            }
        }
        
        // Check diagonals
        if let center = board[1][1] {
            if board[0][0] == center && board[2][2] == center {
                winner = center
                showVictory = true
                return
            }
            if board[0][2] == center && board[2][0] == center {
                winner = center
                showVictory = true
                return
            }
        }
    }
    
    private func canMakeMove(row: Int, col: Int) -> Bool {
        // Can't place on occupied cell
        if board[row][col] != nil { return false }
        
        // Can't place on the cell where a number just disappeared
        if lastDisappearedCell?.row == row && lastDisappearedCell?.col == col {
            return false
        }
        
        return true
    }
    
    private func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 3), count: 3)
        movesLifespan = Array(repeating: Array(repeating: nil, count: 3), count: 3)
        turnCount = 0
        lastDisappearedCell = nil
        isPlayer1Turn = true
        winner = nil
    }
}

struct PlayerCard: View {
    let number: Int
    let isActive: Bool
    let symbol: String  // We won't use this anymore
    
    var body: some View {
        VStack(spacing: 12) {
            playerLabel
            numberCircle  // Renamed from symbolCircle
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(cardBackground)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isActive)
    }
    
    private var playerLabel: some View {
        Text("Player \(number)")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Theme.secondary)
    }
    
    private var numberCircle: some View {
        ZStack {
            Circle()
                .fill(Theme.card)
                .frame(width: 60, height: 60)
                .shadow(color: isActive ? Theme.accent.opacity(0.3) : Color.clear, radius: 8)
            
            Text(String(number))  // Use number instead of symbol
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isActive ? Theme.accent : Theme.secondary)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Theme.card)
            .shadow(color: isActive ? Theme.accent.opacity(0.2) : Color.clear, radius: 6)
    }
}

struct GridCell: View {
    let number: Int?
    let moveTime: Int?
    let currentTurn: Int
    let maxTurns: Int
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Number display
                if let number = number {
                    Text(String(number))
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(Theme.text)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.card)
            .overlay(cellBorder)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cellBorder: some View {
        RoundedRectangle(cornerRadius: 0)
            .stroke(isActive ? Theme.accent : Theme.secondary.opacity(0.3), lineWidth: 1)
    }
} 