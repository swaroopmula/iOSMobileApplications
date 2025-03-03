import SwiftUI

struct BullsAndCowsGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var targetNumber: Int = 0
    @State private var guess = ""
    @State private var attempts = 0
    @State private var guessHistory: [(guess: String, feedback: String)] = []
    @State private var showVictory = false
    @State private var numberStatuses: [String: NumberStatus] = [:]
    @State private var showLost = false
    @State private var showInfo = false
    @State private var showHint = false
    @State private var currentHint = ""
    @State private var hintsRemaining = 3  // Limited hints per game
    @State private var revealedDigits: Set<Int> = []
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - Fixed height
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            showInfo = true
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))  // Make consistent with other games
                            .foregroundColor(Theme.accent)
                    }
                    
                    Spacer()
                    
                    // Add hint button before Give Up
                    Button(action: generateHint) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                            Text("\(hintsRemaining)")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(hintsRemaining > 0 ? Theme.accent : Theme.secondary)
                    }
                    .disabled(hintsRemaining == 0)
                    
                    Button("Give Up") {
                        withAnimation {
                            showLost = true
                        }
                    }
                    .foregroundColor(.red)
                }
                .padding()
                .frame(height: 70)
                
                // Game Status Area - Fixed height
                VStack(spacing: 8) {
                    Text(guess.isEmpty ? "Enter 4 digits" : guess)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(Theme.text)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Theme.card)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .frame(height: 60)
                
                // Show current hint or pattern tip if active
                if showHint && !currentHint.isEmpty {
                    Text(currentHint)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.accent)
                        .padding()
                        .background(Theme.card)
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // History - Flexible height
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(guessHistory.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                Text("\(guessHistory.count - index).")
                                    .foregroundColor(Theme.secondary)
                                    .frame(width: 35, alignment: .leading)
                                Text(guessHistory[index].guess)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 60, alignment: .leading)
                                Spacer()
                                Text(guessHistory[index].feedback)
                                    .foregroundColor(Theme.accent)
                                    .lineLimit(1)
                                    .frame(alignment: .trailing)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.card)
                            .cornerRadius(8)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.6).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: guessHistory.count)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                
                // Add the checklist above the number pad
                NumberCheckList(numberStatuses: $numberStatuses)
                    .padding(.bottom, 12)
                
                // Number Pad - Fixed height
                NumberPad(
                    onNumber: { number in
                        if guess.count < 4 && !guess.contains(number) {
                            guess += number
                        }
                    },
                    onDelete: {
                        if !guess.isEmpty {
                            guess.removeLast()
                        }
                    },
                    onSubmit: checkGuess,
                    submitDisabled: guess.count != 4
                )
                .frame(height: 280)
            }
            
            if showVictory {
                VictoryOverlay(
                    attempts: attempts,
                    onRestart: {
                        showVictory = false
                        restartGame()
                    },
                    onClose: {
                        dismiss()
                    }
                )
            }
            
            if showLost {
                LostOverlay(
                    answer: targetNumber,
                    attempts: attempts,
                    gameType: .bullsAndCows,
                    onRestart: {
                        showLost = false
                        restartGame()
                    },
                    onClose: {
                        dismiss()
                    }
                )
            }
            
            if showInfo {
                InfoOverlay(
                    gameType: .bullsAndCows,
                    onClose: {
                        showInfo = false
                    }
                )
            }
        }
        .onAppear {
            generateNewTargetNumber()
        }
    }
    
    private func generateNewTargetNumber() {
        var digits = Array(0...9)
        digits.shuffle()
        targetNumber = digits[0] * 1000 + digits[1] * 100 + digits[2] * 10 + digits[3]
    }
    
    private func restartGame() {
        generateNewTargetNumber()
        guess = ""
        attempts = 0
        guessHistory.removeAll()
        numberStatuses.removeAll()
        showVictory = false
        showLost = false
        hintsRemaining = 3
        revealedDigits.removeAll()  // Reset revealed digits
    }
    
    private func checkGuess() {
        guard guess.count == 4 else {
            guessHistory.insert((guess: guess, feedback: "Enter a 4-digit number!"), at: 0)
            guess = ""
            return
        }

        attempts += 1
        var bulls = 0
        var cows = 0

        let targetDigits = Array(String(format: "%04d", targetNumber))
        let guessDigits = Array(guess)
        var usedTargetIndices = Set<Int>()
        var usedGuessIndices = Set<Int>()

        // Count bulls
        for i in 0..<4 {
            if guessDigits[i] == targetDigits[i] {
                bulls += 1
                usedTargetIndices.insert(i)
                usedGuessIndices.insert(i)
            }
        }

        // Count cows
        for i in 0..<4 where !usedGuessIndices.contains(i) {
            for j in 0..<4 where !usedTargetIndices.contains(j) {
                if guessDigits[i] == targetDigits[j] {
                    cows += 1
                    usedTargetIndices.insert(j)
                    break
                }
            }
        }

        guessHistory.insert((guess: guess, feedback: "\(bulls) Bulls, \(cows) Cows"), at: 0)
        guess = ""

        if bulls == 4 {
            withAnimation {
                showVictory = true
            }
        }
    }
    
    private func generateHint() {
        guard hintsRemaining > 0 else { return }
        
        // Convert target number to array of digits
        let targetDigits = Array(String(format: "%04d", targetNumber))
        
        // Filter out already revealed digits
        let availableDigits = targetDigits.enumerated().filter { !revealedDigits.contains($0.element.wholeNumberValue ?? 0) }
        
        if let randomHint = availableDigits.randomElement() {
            // Add the digit to revealed set
            revealedDigits.insert(randomHint.element.wholeNumberValue ?? 0)
            
            // Show the hint
            currentHint = "The number contains digit: \(randomHint.element)"
            
            hintsRemaining -= 1
            withAnimation {
                showHint = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showHint = false
                    currentHint = ""
                }
            }
        } else {
            // All digits have been revealed
            currentHint = "No more hints available!"
            withAnimation {
                showHint = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showHint = false
                    currentHint = ""
                }
            }
        }
    }
}

// Add extension to parse bulls/cows from feedback string
extension String {
    func getBullsAndCows() -> (bulls: Int, cows: Int) {
        let components = self.components(separatedBy: ",")
        let bulls = Int(components[0].trimmingCharacters(in: .letters)) ?? 0
        let cows = Int(components[1].trimmingCharacters(in: .letters)) ?? 0
        return (bulls, cows)
    }
} 
