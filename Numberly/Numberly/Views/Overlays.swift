import SwiftUI

struct VictoryOverlay: View {
    let attempts: Int
    var winnerNumber: Int? = nil
    let onRestart: () -> Void
    let onClose: () -> Void
    @State private var showCard = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}
            
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.5))
                            .frame(width: 120, height: 120)
                            .blur(radius: showCard ? 15 : 5)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FFD700"))
                            .rotationEffect(.degrees(showCard ? 360 : 0))
                            .scaleEffect(showCard ? 1 : 0.5)
                    }
                    
                    VStack(spacing: 8) {
                        Text("VICTORY!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Theme.text)
                        
                        if let winner = winnerNumber {
                            Text("Player \(winner) Wins!")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.accent)
                        }
                        
                        Text("Game completed in \(attempts) turns")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.secondary)
                    }
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onRestart()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Theme.accent)
                        .cornerRadius(25)
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onClose()
                        }
                    }) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .frame(width: 220, height: 50)
                            .background(Theme.card)
                            .cornerRadius(25)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.background)
                    .shadow(color: Theme.accent.opacity(0.5), radius: 30)
            )
            .scaleEffect(showCard ? 1 : 0.5)
            .opacity(showCard ? 1 : 0)
        }
        .opacity(showCard ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCard = true
            }
        }
    }
}

struct LostOverlay: View {
    let answer: Int
    let attempts: Int
    let gameType: GameMode
    let onRestart: () -> Void
    let onClose: () -> Void
    @State private var showCard = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}
            
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .blur(radius: showCard ? 15 : 5)
                        
                        VStack(spacing: -5) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text("GAME OVER")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .rotationEffect(.degrees(showCard ? 360 : 0))
                        .scaleEffect(showCard ? 1 : 0.5)
                    }
                    
                    VStack(spacing: 12) {
                        if gameType == .bullsAndCows {
                            Text("Answer: \(String(format: "%04d", answer))")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.text)
                        } else if gameType == .sudoku {
                            Text("Too many mistakes!")  // Custom message for Sudoku
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.text)
                        } else {
                            Text("Answer: \(answer)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.text)
                        }
                        
                        Text("\(attempts) \(gameType == .sudoku ? "mistakes" : "attempts") made")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.secondary)
                    }
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onRestart()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(25)
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onClose()
                        }
                    }) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .frame(width: 220, height: 50)
                            .background(Theme.card)
                            .cornerRadius(25)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.background)
                    .shadow(color: Color.red.opacity(0.3), radius: 30)
            )
            .scaleEffect(showCard ? 1 : 0.5)
            .opacity(showCard ? 1 : 0)
        }
        .opacity(showCard ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCard = true
            }
        }
    }
}

struct InfoOverlay: View {
    let gameType: GameMode
    let onClose: () -> Void
    @State private var showCard = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        onClose()
                    }
                }
            
            VStack(spacing: 25) {
                Text("How to Play")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.text)
                
                if gameType == .bullsAndCows {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionRow(
                            icon: "123.rectangle.fill",
                            title: "The Goal",
                            detail: "Guess a 4-digit number with unique digits"
                        )
                        
                        instructionRow(
                            icon: "checkmark.circle.fill",
                            title: "Bulls",
                            detail: "Correct digit in correct position"
                        )
                        
                        instructionRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Cows",
                            detail: "Correct digit in wrong position"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Example:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Theme.accent)
                            Text("Secret number: 1234")
                                .foregroundColor(Theme.secondary)
                            Text("Guess: 1567 → 1 Bull")
                                .foregroundColor(Theme.text)
                            Text("Guess: 2140 → 2 Cows")
                                .foregroundColor(Theme.text)
                        }
                        .padding(.top, 5)
                    }
                } else if gameType == .higherLower {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionRow(
                            icon: "target",
                            title: "The Goal",
                            detail: "Find the secret number between 1 and 100"
                        )
                        
                        instructionRow(
                            icon: "arrow.up.circle.fill",
                            title: "Higher",
                            detail: "Your guess is too low"
                        )
                        
                        instructionRow(
                            icon: "arrow.down.circle.fill",
                            title: "Lower",
                            detail: "Your guess is too high"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Example:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Theme.accent)
                            Text("Secret number: 75")
                                .foregroundColor(Theme.secondary)
                            Text("Guess: 50 → Higher!")
                                .foregroundColor(Theme.text)
                            Text("Guess: 90 → Lower!")
                                .foregroundColor(Theme.text)
                        }
                        .padding(.top, 5)
                    }
                } else if gameType == .sudoku {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionRow(
                            icon: "grid",
                            title: "The Goal",
                            detail: "Fill the 9x9 grid with numbers 1-9"
                        )
                        
                        instructionRow(
                            icon: "square.grid.3x3",
                            title: "Rules",
                            detail: "Each row, column, and 3x3 box must contain numbers 1-9 without repeating"
                        )
                        
                        instructionRow(
                            icon: "xmark.circle",
                            title: "Mistakes",
                            detail: "You have 3 chances to make mistakes before losing"
                        )
                        
                        instructionRow(
                            icon: "lightbulb.fill",
                            title: "Hints",
                            detail: "Use hints wisely - you only get 3!"
                        )
                    }
                } else if gameType == .numTacShift {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionRow(
                            icon: "person.2.fill",
                            title: "2 Players",
                            detail: "Player 1 uses 1s, Player 2 uses 0s"
                        )
                        
                        instructionRow(
                            icon: "clock.fill",
                            title: "Shifting Numbers",
                            detail: "Numbers disappear after 6 turns"
                        )
                        
                        instructionRow(
                            icon: "trophy.fill",
                            title: "Victory",
                            detail: "Get three in a row to win"
                        )
                        
                        instructionRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Strategy",
                            detail: "Plan ahead! Your numbers will disappear as the game progresses"
                        )
                    }
                } else if gameType == .sumRush {
                    VStack(alignment: .leading, spacing: 20) {
                        instructionRow(
                            icon: "sum",
                            title: "The Goal",
                            detail: "Add numbers to match the target sum"
                        )
                        
                        instructionRow(
                            icon: "clock.fill",
                            title: "Time Limit",
                            detail: "Complete as many targets as possible in 30 seconds"
                        )
                        
                        instructionRow(
                            icon: "plus.circle.fill",
                            title: "Time Bonus",
                            detail: "First hit: +5s\nCombo x2: +6s\nCombo x3: +7s\nAnd so on up to +10s"
                        )
                        
                        instructionRow(
                            icon: "flame.fill",
                            title: "Combo System",
                            detail: "Keep hitting exact targets to build your combo. Exceeding the target breaks your combo!"
                        )
                        
                        instructionRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Difficulty",
                            detail: "Game gets harder every 2 targets. More numbers and bigger sums!"
                        )
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        onClose()
                    }
                }) {
                    Text("Got it!")
                        .font(.headline)
                        .foregroundColor(Theme.background)
                        .frame(width: 220, height: 50)
                        .background(Theme.accent)
                        .cornerRadius(25)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.background)
                    .shadow(color: Theme.accent.opacity(0.5), radius: 30)
            )
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .scaleEffect(showCard ? 1 : 0.5)
            .opacity(showCard ? 1 : 0)
        }
        .opacity(showCard ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCard = true
            }
        }
    }
    
    private func instructionRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.text)
                Text(detail)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct ResultOverlay: View {
    let targetsReached: Int
    let onRestart: () -> Void
    let onClose: () -> Void
    @State private var showCard = false
    
    private var resultMessage: String {
        if targetsReached == 0 {
            return "Keep practicing!"
        } else if targetsReached < 5 {
            return "Good effort!"
        } else if targetsReached < 10 {
            return "Well done!"
        } else {
            return "Amazing!"
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}
            
            VStack(spacing: 25) {
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .blur(radius: showCard ? 15 : 5)
                        
                        VStack(spacing: -5) {
                            Image(systemName: "stopwatch.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Theme.accent)
                            Text("TIME'S UP")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }
                        .rotationEffect(.degrees(showCard ? 360 : 0))
                        .scaleEffect(showCard ? 1 : 0.5)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Targets Hit: \(targetsReached)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.text)
                        
                        Text(resultMessage)
                            .font(.system(size: 18))
                            .foregroundColor(Theme.secondary)
                    }
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onRestart()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
                        }
                        .font(.headline)
                        .foregroundColor(Theme.background)
                        .frame(width: 200, height: 50)
                        .background(Theme.accent)
                        .cornerRadius(25)
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            onClose()
                        }
                    }) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .frame(width: 200, height: 50)
                            .background(Theme.card)
                            .cornerRadius(25)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Theme.background)
                    .shadow(color: Theme.accent.opacity(0.3), radius: 30)
            )
            .scaleEffect(showCard ? 1 : 0.5)
            .opacity(showCard ? 1 : 0)
        }
        .opacity(showCard ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCard = true
            }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakes: CGFloat = 3
    var animatableData: CGFloat
    
    init(shakes: Int) {
        self.animatableData = CGFloat(shakes)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * 2), y: 0))
    }
} 
