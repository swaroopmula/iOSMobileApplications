import SwiftUI

struct HigherLowerGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var targetNumber: Int = 0
    @State private var guess = ""
    @State private var attempts = 0
    @State private var guessHistory: [(guess: String, feedback: String)] = []
    @State private var showVictory = false
    @State private var showLost = false
    @State private var showInfo = false
    @State private var rangeStart = 1
    @State private var rangeEnd = 100
    @State private var showTip = false
    @State private var lastDistance: Int?
    
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
                            .font(.system(size: 20))
                            .foregroundColor(Theme.accent)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showTip.toggle()
                        }
                    }) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.accent)
                    }
                    
                    Button("Give Up") {
                        withAnimation {
                            showLost = true
                        }
                    }
                    .foregroundColor(.red)
                    
                    
                }
                .padding()
                .frame(height: 70)
                
                // Show range and temperature only when tip is active
                if showTip {
                    VStack(spacing: 8) {
                        Text("Range: \(rangeStart) - \(rangeEnd)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.secondary)
                        
                        // Visual range bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Full range background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.card)
                                    .frame(height: 8)
                                
                                // Active range
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.accent)
                                    .frame(
                                        width: geometry.size.width * 
                                            CGFloat(rangeEnd - rangeStart) / 100.0,
                                        height: 8
                                    )
                                    .offset(x: geometry.size.width * 
                                        CGFloat(rangeStart - 1) / 100.0)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        
                        // Temperature indicator
                        if let lastGuess = guessHistory.last, let distance = lastDistance {
                            HStack(spacing: 12) {
                                Image(systemName: getTemperatureIcon(distance: distance))
                                    .font(.system(size: 24))
                                    .foregroundColor(getTemperatureColor(distance: distance))
                                
                                Text(getTemperatureText(distance: distance))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.text)
                            }
                            .padding()
                            .background(Theme.card)
                            .cornerRadius(12)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Game Status Area - Fixed height
                VStack(spacing: 8) {
                    Text(guess.isEmpty ? "Enter number" : guess)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(Theme.text)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Theme.card)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .frame(height: 60)
                
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
                                    .frame(width: 40, alignment: .leading)
                                Spacer()
                                Text(guessHistory[index].feedback)
                                    .foregroundColor(
                                        guessHistory[index].feedback.contains("Higher") ? Color.red.opacity(0.8) :
                                        guessHistory[index].feedback.contains("Lower") ? Color(hex: "3B82F6") :
                                        Theme.accent
                                    )
                                    .fontWeight(.medium)
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
                
                // Number Pad - Fixed height
                NumberPad(
                    onNumber: { number in
                        let newGuess = guess + number
                        
                        // Handle special cases
                        if guess.isEmpty {
                            // First digit must be 1-9
                            if number != "0" {
                                guess = number
                            }
                        } else if guess == "1" && number == "0" && guess.count == 1 {
                            // Allow 100
                            guess = "10"
                        } else if guess == "10" && number == "0" {
                            // Complete 100
                            guess = "100"
                        } else if guess.count < 2 && guess != "10" {
                            // Allow second digit for numbers less than 100
                            if let value = Int(newGuess), value > 0, value < 100 {
                                guess = newGuess
                            }
                        }
                    },
                    onDelete: {
                        if !guess.isEmpty {
                            guess.removeLast()
                        }
                    },
                    onSubmit: checkGuess,
                    submitDisabled: guess.isEmpty || (Int(guess) ?? 0) > 100 || (Int(guess) ?? 0) < 1
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
                    gameType: .higherLower,
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
                    gameType: .higherLower,
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
        targetNumber = Int.random(in: 1...100)
    }
    
    private func restartGame() {
        generateNewTargetNumber()
        guess = ""
        attempts = 0
        guessHistory.removeAll()
        showVictory = false
        showLost = false
    }
    
    private func checkGuess() {
        guard let number = Int(guess) else { return }
        
        let currentDistance = abs(number - targetNumber)
        
        // Update range based on guess
        if number < targetNumber {
            rangeStart = max(rangeStart, number + 1)
            guessHistory.insert((guess: guess, feedback: "↑ Higher!"), at: 0)
        } else if number > targetNumber {
            rangeEnd = min(rangeEnd, number - 1)
            guessHistory.insert((guess: guess, feedback: "↓ Lower!"), at: 0)
        } else {
            withAnimation {
                showVictory = true
            }
            return
        }
        
        // Update temperature indicator
        lastDistance = currentDistance
        
        guess = ""
        attempts += 1
    }
    
    // Helper functions for temperature indication
    private func getTemperatureIcon(distance: Int) -> String {
        switch distance {
        case 0...5: return "flame.fill"
        case 6...15: return "flame"
        case 16...30: return "thermometer.high"
        case 31...50: return "thermometer.medium"
        default: return "thermometer.low"
        }
    }
    
    private func getTemperatureColor(distance: Int) -> Color {
        switch distance {
        case 0...5: return .red
        case 6...15: return .orange
        case 16...30: return .yellow
        case 31...50: return .blue
        default: return .purple
        }
    }
    
    private func getTemperatureText(distance: Int) -> String {
        switch distance {
        case 0...5: return "Very Hot!"
        case 6...15: return "Hot!"
        case 16...30: return "Warm"
        case 31...50: return "Cold"
        default: return "Very Cold"
        }
    }
} 
