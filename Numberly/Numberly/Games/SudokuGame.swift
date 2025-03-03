import SwiftUI

struct SudokuGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var board: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
    @State private var initialBoard: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
    @State private var selectedCell: (row: Int, col: Int)? = nil
    @State private var showVictory = false
    @State private var showInfo = false
    @State private var mistakes = 0
    @State private var showHint = false
    @State private var currentHint = ""
    @State private var hintsRemaining = 3
    @State private var showLost = false
    @State private var solution: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
    @State private var showMistakeFlash = false
    @State private var placeholders: [[Set<Int>]] = Array(repeating: Array(repeating: [], count: 9), count: 9)
    @State private var isPlaceholderMode = false
    @State private var sudokuGridRef: SudokuGrid?
    @State private var showMistake = false
    
    private let cellSize: CGFloat = 36
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                GameHeader(
                    title: "Sudoku",
                    onDismiss: { dismiss() },
                    onInfo: { showInfo = true },
                    additionalButton: {
                        AnyView(
                            Button(action: {
                                withAnimation { isPlaceholderMode.toggle() }
                            }) {
                                Image(systemName: isPlaceholderMode ? "pencil.circle.fill" : "pencil.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(isPlaceholderMode ? Theme.accent : Theme.secondary)
                            }
                        )
                    }
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Game Status
                        HStack(spacing: 20) {
                            // Mistakes with light red background
                            VStack(spacing: 4) {
                                Text("Mistakes")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.secondary)
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { index in
                                        Circle()
                                            .fill(index < mistakes ? Color.red : Color.red.opacity(0.2))
                                            .frame(width: 10, height: 10)
                                    }
                                }
                            }
                            
                            Divider()
                                .frame(height: 30)
                                .background(Theme.secondary)
                            
                            // Hints
                            VStack(spacing: 4) {
                                Text("Hints")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.secondary)
                                HStack(spacing: 4) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14))
                                    Text("\(hintsRemaining)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(hintsRemaining > 0 ? Theme.accent : Theme.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Theme.card)
                        .cornerRadius(12)
                        
                        // Hint Display
                        if showHint && !currentHint.isEmpty {
                            Text(currentHint)
                                .font(.system(size: 16))
                                .foregroundColor(Theme.accent)
                                .padding()
                                .background(Theme.card)
                                .cornerRadius(10)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Sudoku Grid
                        SudokuGrid(
                            board: $board,
                            initialBoard: initialBoard,
                            selectedCell: $selectedCell,
                            placeholders: $placeholders,
                            showMistake: $showMistake
                        )
                        .padding(.horizontal)
                        
                        // Number Input Section
                        VStack(spacing: 12) {
                            // Number Pad
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(1...9, id: \.self) { number in
                                    SudokuNumberButton(
                                        number: String(number),
                                        action: handleNumberInput
                                    )
                                }
                            }
                            
                            HStack(spacing: 8) {
                                // Delete button
                                Button(action: handleDelete) {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 24))
                                        .foregroundColor(Theme.text)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Theme.card)
                                        .cornerRadius(12)
                                }
                                
                                // Hint button
                                if hintsRemaining > 0 {
                                    Button(action: generateHint) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(Theme.accent)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(Theme.card)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding(.top, 20)
                }
            }
            
            // Overlays
            if showVictory {
                VictoryOverlay(
                    attempts: mistakes,
                    onRestart: {
                        showVictory = false
                        restartGame()
                    },
                    onClose: { dismiss() }
                )
            }
            
            if showInfo {
                InfoOverlay(
                    gameType: .sudoku,
                    onClose: { showInfo = false }
                )
            }
            
            if showLost {
                LostOverlay(
                    answer: 0,  // This won't be displayed for Sudoku
                    attempts: mistakes,
                    gameType: .sudoku,
                    onRestart: {
                        showLost = false
                        restartGame()
                    },
                    onClose: { dismiss() }
                )
            }
        }
        .onAppear { startGame() }
    }
    
    private func startGame() {
        generateNewPuzzle()
        mistakes = 0
        hintsRemaining = 3
        showVictory = false
        showLost = false
    }
    
    private func restartGame() {
        board = initialBoard.map { row in
            row.map { $0 }
        }
        mistakes = 0
        hintsRemaining = 3
        showVictory = false
        showLost = false
        selectedCell = nil
    }
    
    private func generateNewPuzzle() {
        // First, generate a valid solution
        generateSolution()
        solution = board.map { row in
            row.map { $0 }  // Create a copy of the board
        }
        
        // Create the puzzle by removing numbers
        initialBoard = board.map { row in
            row.map { $0 }  // Create a copy of the board
        }
        let cellsToRemove = 45  // Adjust difficulty by changing this number
        var removedCells = 0
        
        while removedCells < cellsToRemove {
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            
            if initialBoard[row][col] != nil {
                initialBoard[row][col] = nil
                removedCells += 1
            }
        }
        
        board = initialBoard.map { row in
            row.map { $0 }  // Create a copy of the board
        }
    }
    
    private func generateSolution() {
        // Clear the board
        board = Array(repeating: Array(repeating: nil, count: 9), count: 9)
        
        // Fill diagonal 3x3 boxes first (they're independent)
        for i in stride(from: 0, to: 9, by: 3) {
            fillBox(startRow: i, startCol: i)
        }
        
        // Fill the rest
        _ = solveSudoku()  // Add underscore to explicitly ignore the result
    }
    
    private func fillBox(startRow: Int, startCol: Int) {
        var numbers = Array(1...9)
        numbers.shuffle()
        
        var index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                board[startRow + i][startCol + j] = numbers[index]
                index += 1
            }
        }
    }
    
    private func solveSudoku() -> Bool {
        guard let emptyCell = findEmptyCell() else { return true }
        let (row, col) = emptyCell
        
        for num in 1...9 {
            if isValidMove(row: row, col: col, number: num) {
                board[row][col] = num
                
                if solveSudoku() {
                    return true
                }
                
                board[row][col] = nil
            }
        }
        
        return false
    }
    
    private func findEmptyCell() -> (Int, Int)? {
        for i in 0..<9 {
            for j in 0..<9 {
                if board[i][j] == nil {
                    return (i, j)
                }
            }
        }
        return nil
    }
    
    private func isValidMove(row: Int, col: Int, number: Int) -> Bool {
        // Check row
        for j in 0..<9 {
            if board[row][j] == number {
                return false
            }
        }
        
        // Check column
        for i in 0..<9 {
            if board[i][col] == number {
                return false
            }
        }
        
        // Check 3x3 box
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        
        for i in 0..<3 {
            for j in 0..<3 {
                if board[boxRow + i][boxCol + j] == number {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func isRelatedCell(row: Int, col: Int) -> Bool {
        guard let selected = selectedCell else { return false }
        
        // Same row or column
        if row == selected.row || col == selected.col {
            return true
        }
        
        // Same 3x3 box
        let selectedBoxRow = (selected.row / 3) * 3
        let selectedBoxCol = (selected.col / 3) * 3
        let cellBoxRow = (row / 3) * 3
        let cellBoxCol = (col / 3) * 3
        
        return selectedBoxRow == cellBoxRow && selectedBoxCol == cellBoxCol
    }
    
    private func isBoardComplete() -> Bool {
        for i in 0..<9 {
            for j in 0..<9 {
                guard let boardValue = board[i][j],
                      let solutionValue = solution[i][j],
                      boardValue == solutionValue else {
                    return false
                }
            }
        }
        return true
    }
    
    private func generateHint() {
        guard hintsRemaining > 0 else { return }
        
        // Find a random empty or incorrect cell
        var emptyCells: [(Int, Int)] = []
        for i in 0..<9 {
            for j in 0..<9 {
                if board[i][j] != solution[i][j] {
                    emptyCells.append((i, j))
                }
            }
        }
        
        if let (row, col) = emptyCells.randomElement(), 
           let correctNumber = solution[row][col] {
            // Temporarily show the number with highlight
            withAnimation(.easeInOut(duration: 0.3)) {
                board[row][col] = correctNumber
                selectedCell = (row, col)
                hintsRemaining -= 1
            }
            
            // Flash effect
            withAnimation(.easeInOut(duration: 0.5).repeatCount(3)) {
                showHint = true
            }
            
            // Reset highlight after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showHint = false
                }
            }
        }
    }
    
    private func handleNumberInput(_ numberString: String) {
        guard let (row, col) = selectedCell,
              initialBoard[row][col] == nil,
              let number = Int(numberString) else { return }
        
        if isPlaceholderMode {
            withAnimation(.easeInOut(duration: 0.2)) {
                if placeholders[row][col].contains(number) {
                    placeholders[row][col].remove(number)
                } else if placeholders[row][col].count < 4 {
                    placeholders[row][col].insert(number)
                }
            }
        } else {
            if isValidMove(row: row, col: col, number: number) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    board[row][col] = number
                    placeholders[row][col].removeAll()
                    if isBoardComplete() {
                        showVictory = true
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    mistakes += 1
                    showMistake = true
                    if mistakes >= 3 {
                        showLost = true
                    }
                }
            }
        }
    }
    
    private func handleDelete() {
        guard let (row, col) = selectedCell,
              initialBoard[row][col] == nil else { return }
        
        withAnimation {
            board[row][col] = nil
        }
    }
}

struct SudokuCell: View {
    let number: Int?
    let isInitial: Bool
    let isSelected: Bool
    let isRelated: Bool
    let onTap: () -> Void
    let showHint: Bool
    let placeholders: Set<Int>
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let number = number {
                    Text(String(number))
                        .font(.system(size: 20, weight: isInitial ? .bold : .medium))
                        .foregroundColor(Theme.text)
                } else if !placeholders.isEmpty {
                    ZStack {
                        // Fixed positions for placeholders (1-4)
                        ForEach(Array(placeholders.sorted().prefix(4)), id: \.self) { num in
                            Text(String(num))
                                .font(.system(size: 10))
                                .foregroundColor(Theme.accent)
                                .position(
                                    x: num <= 2 ? 12 : 28,  // Left or Right
                                    y: num.isMultiple(of: 2) ? 28 : 12  // Top or Bottom
                                )
                        }
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    if showHint {
                        Theme.accent.opacity(0.4)
                    } else if isSelected {
                        Theme.accent.opacity(0.3)
                    } else if isRelated {
                        Theme.accent.opacity(0.1)
                    } else {
                        Theme.card
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// New component for 3x3 blocks
struct SudokuBlock: View {
    let startRow: Int
    let startCol: Int
    let board: [[Int?]]
    let initialBoard: [[Int?]]
    let selectedCell: (row: Int, col: Int)?
    let onCellTap: (Int, Int) -> Void
    let placeholders: [[Set<Int>]]
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { i in
                HStack(spacing: 1) {
                    ForEach(0..<3) { j in
                        let row = startRow + i
                        let col = startCol + j
                        SudokuCell(
                            number: board[row][col],
                            isInitial: initialBoard[row][col] != nil,
                            isSelected: selectedCell?.row == row && selectedCell?.col == col,
                            isRelated: isRelatedCell(row: row, col: col),
                            onTap: { onCellTap(row, col) },
                            showHint: false,
                            placeholders: placeholders[row][col]
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            GeometryReader { geometry in
                                Path { path in
                                    // Right border
                                    if j < 2 {
                                        path.move(to: CGPoint(x: geometry.size.width, y: 0))
                                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                                    }
                                    // Bottom border
                                    if i < 2 {
                                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                                    }
                                }
                                .stroke(Theme.secondary.opacity(0.3), lineWidth: 1)
                            }
                        )
                    }
                }
            }
        }
        .background(Theme.card)
        .cornerRadius(4)
    }
    
    private func isRelatedCell(row: Int, col: Int) -> Bool {
        guard let selected = selectedCell else { return false }
        return row == selected.row || col == selected.col ||
            (row / 3 == selected.row / 3 && col / 3 == selected.col / 3)
    }
}

// Sudoku Grid Component
struct SudokuGrid: View {
    @Binding var board: [[Int?]]
    let initialBoard: [[Int?]]
    @Binding var selectedCell: (row: Int, col: Int)?
    @Binding var placeholders: [[Set<Int>]]
    @Binding var showMistake: Bool
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3) { blockRow in
                HStack(spacing: 3) {
                    ForEach(0..<3) { blockCol in
                        SudokuBlock(
                            startRow: blockRow * 3,
                            startCol: blockCol * 3,
                            board: board,
                            initialBoard: initialBoard,
                            selectedCell: selectedCell,
                            onCellTap: { row, col in
                                withAnimation {
                                    selectedCell = (row, col)
                                }
                            },
                            placeholders: placeholders
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Theme.secondary.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(3)
        .background(Theme.secondary.opacity(0.3))
        .cornerRadius(12)
        .modifier(BounceAnimationModifier(isActive: showMistake))
        .onChange(of: showMistake) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMistake = false
                }
            }
        }
    }
}

// Custom Number Pad
struct NumberPadView: View {
    let onNumber: (String) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { num in
                        SudokuNumberButton(number: String(row * 3 + num), action: onNumber)
                    }
                }
            }
            HStack(spacing: 8) {
                SudokuNumberButton(number: "7", action: onNumber)
                SudokuNumberButton(number: "8", action: onNumber)
                SudokuNumberButton(number: "9", action: onNumber)
            }
            Button(action: onDelete) {
                Image(systemName: "delete.left")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Theme.card)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

// Add this new struct for Sudoku number buttons
struct SudokuNumberButton: View {
    let number: String
    let action: (String) -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { action(number) }) {
            Text(number)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Theme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Theme.card
                        .overlay(
                            Theme.accent.opacity(isPressed ? 0.2 : 0)
                        )
                )
                .cornerRadius(12)
                .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true },
                    onRelease: { isPressed = false })
    }
}

// Add this extension for press events
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

// Replace MistakeFlashModifier with a bounce animation
struct BounceAnimationModifier: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(isActive ? 0.15 : 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(isActive ? 0.8 : 0), lineWidth: 4)
                    )
            )
            .scaleEffect(isActive ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.5), value: isActive)
    }
} 
