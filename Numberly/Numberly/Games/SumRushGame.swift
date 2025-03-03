import SwiftUI

struct SumRushGame: View {
    @Environment(\.dismiss) private var dismiss
    @State private var targetSum: Int = 0
    @State private var currentSum: Int = 0
    @State private var selectedNumbers: Set<Int> = []
    @State private var timeRemaining: Double = 30.0
    @State private var targetsReached: Int = 0
    @State private var showResult = false
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var gridNumbers: [Int] = Array(1...12)
    @State private var animateTarget = false
    @State private var shake = false
    @State private var showTimeBonus = false
    @State private var showInfo = false
    @State private var isPaused = false
    @State private var currentCombo: Int = 0
    @State private var maxCombo: Int = 0
    @State private var difficultyLevel: Int = 1
    @State private var currentTimeBonus: Double = 5.0
    @State private var isActive = false
    @State private var lastComboTime: Date? = nil
    
    private let maxTime: Double = 30.0
    private let comboTimeout: TimeInterval = 2.0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with Timer and Close Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Theme.secondary)
                            .padding(8)
                            .background(Color.clear)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        withAnimation {
                            showInfo = true
                            isPaused = true
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.accent)
                            .padding(8)
                            .background(Color.clear)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Improved timer animation
                    HStack(spacing: 0) {
                        Text(String(format: "%.1f", timeRemaining))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(timeRemaining <= 10 ? .red : Theme.text)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Theme.card.opacity(0.8))
                            .cornerRadius(10)
                            .offset(x: showTimeBonus ? -20 : 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showTimeBonus)
                        
                        if showTimeBonus {
                            Text("+\(String(format: "%.1f", currentTimeBonus))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.accent)
                                .padding(4)
                                .background(Theme.card)
                                .cornerRadius(4)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.5).combined(with: .opacity),
                                    removal: .scale(scale: 1.5).combined(with: .opacity)
                                ))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showTimeBonus = false
                                        }
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Add combo display near the top
                comboView
                
                // Target Sum with Animation
                VStack(alignment: .center, spacing: 4) {
                    Text("Target")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.text)
                    Text("\(targetSum)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Theme.text)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Theme.card.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .scaleEffect(animateTarget ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateTarget)
                }
                
                // Current Sum with Shake Animation
                VStack(alignment: .center, spacing: 4) {
                    Text("Current")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.text)
                    Text("\(currentSum)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(currentSum > targetSum ? .red : Theme.text)
                        .padding(.vertical, 8)
                        .modifier(ShakeEffect(shakes: shake ? 2 : 0))
                        .animation(.default, value: shake)
                }
                
                // Targets Reached Counter
                Text("Targets Hit: \(targetsReached)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.accent)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Theme.card.opacity(0.5))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Number Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridColumns), spacing: 16) {
                    ForEach(gridNumbers, id: \.self) { number in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                toggleNumber(number)
                            }
                        }) {
                            Text("\(number)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.text)
                                .frame(width: 80, height: 80)
                                .background(selectedNumbers.contains(number) ? Theme.accent.opacity(0.2) : Theme.card)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedNumbers.contains(number) ? Theme.accent : Theme.card, lineWidth: 2)
                                )
                                .scaleEffect(selectedNumbers.contains(number) ? 0.95 : 1)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding(.top, 20)
            
            if showResult {
                ResultOverlay(
                    targetsReached: targetsReached,
                    onRestart: {
                        showResult = false
                        resetGame()
                    },
                    onClose: { dismiss() }
                )
            }
            
            // Add Info Overlay
            if showInfo {
                InfoOverlay(
                    gameType: .sumRush,
                    onClose: {
                        withAnimation {
                            showInfo = false
                            isPaused = false
                        }
                    }
                )
            }
        }
        .onAppear {
            resetGame()
            isActive = true
        }
        .onReceive(timer) { _ in
            guard isActive && !isPaused else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 0.1
                
                // Check for combo timeout
                if let lastCombo = lastComboTime,
                   Date().timeIntervalSince(lastCombo) >= comboTimeout {
                    withAnimation {
                        currentCombo = 0
                        lastComboTime = nil
                    }
                }
            } else {
                endGame()
            }
        }
    }
    
    // Calculate grid columns based on difficulty
    private var gridColumns: Int {
        switch difficultyLevel {
        case 1...3:
            return 3
        case 4...6:
            return 4
        default:
            return 5
        }
    }
    
    private func toggleNumber(_ number: Int) {
        guard timeRemaining > 0 else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedNumbers.contains(number) {
                selectedNumbers.remove(number)
            } else {
                selectedNumbers.insert(number)
            }
            
            currentSum = selectedNumbers.reduce(0, +)
            
            if currentSum == targetSum {
                handleCorrectSum()
            } else if currentSum > targetSum {
                handleIncorrectSum()
            }
        }
    }
    
    private func handleCorrectSum() {
        // Update combo and score
        currentCombo += 1
        maxCombo = max(maxCombo, currentCombo)
        targetsReached += 1
        lastComboTime = Date()
        
        // Calculate time bonus based on combo
        let timeBonus: Double
        switch currentCombo {
        case 1:  // First hit
            timeBonus = 5.0
        case 2:  // Combo x2
            timeBonus = 6.0
        case 3:  // Combo x3
            timeBonus = 7.0
        case 4:  // Combo x4
            timeBonus = 8.0
        case 5:  // Combo x5
            timeBonus = 9.0
        default: // Combo x6 or higher
            timeBonus = 10.0
        }
        
        // Apply the time bonus
        currentTimeBonus = timeBonus
        timeRemaining = min(timeRemaining + timeBonus, maxTime)
        
        // Show bonus animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showTimeBonus = true
        }
        
        // Clear current selection
        selectedNumbers.removeAll()
        currentSum = 0
        
        // Increase difficulty every 2 targets
        if targetsReached > 0 && targetsReached % 2 == 0 {
            difficultyLevel += 1
        }
        
        // Generate new target
        generateNewTarget()
    }
    
    private func handleIncorrectSum() {
        // Reset combo when exceeding target
        currentCombo = 0
        lastComboTime = nil
        
        // Clear selection
        selectedNumbers.removeAll()
        currentSum = 0
        
        // Show error animation
        withAnimation(.spring(response: 0.3)) {
            shake = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shake = false
        }
    }
    
    private func generateNewTarget() {
        // Calculate target range based on difficulty
        let minTarget = 15 + ((difficultyLevel - 1) * 5)  // Level 1: 15-25, Level 2: 20-30, Level 3: 25-35...
        let maxTarget = 25 + ((difficultyLevel - 1) * 5)  // Level 1: 15-25, Level 2: 20-30, Level 3: 25-35...
        targetSum = Int.random(in: minTarget...maxTarget)
        
        // Animate the target change
        withAnimation(.spring(response: 0.3)) {
            animateTarget = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animateTarget = false
        }
        
        generateGridNumbers()
        
        // Ensure the target is achievable with current grid numbers
        while !isTargetAchievable() {
            generateGridNumbers()
        }
    }
    
    private func generateGridNumbers() {
        withAnimation(.spring(response: 0.3)) {
            // Calculate number ranges based on difficulty
            let minNumber = 1 + difficultyLevel  // Increases with difficulty
            let maxNumber = targetSum - 1  // Ensure numbers can be combined to reach target
            
            var numbers: [Int] = []
            
            // Always include some smaller numbers for flexibility
            for _ in 0..<3 {
                numbers.append(Int.random(in: minNumber...min(minNumber + 5, maxNumber)))
            }
            
            // Include some medium numbers
            let mediumMin = targetSum / 4
            let mediumMax = targetSum / 2
            for _ in 0..<4 {
                numbers.append(Int.random(in: mediumMin...mediumMax))
            }
            
            // Add larger numbers for higher difficulties
            while numbers.count < gridColumns * 4 {
                if difficultyLevel >= 3 {
                    // More challenging numbers in higher difficulties
                    numbers.append(Int.random(in: mediumMax...maxNumber))
                } else {
                    // More balanced mix in lower difficulties
                    numbers.append(Int.random(in: minNumber...maxNumber))
                }
            }
            
            gridNumbers = numbers.shuffled()
        }
    }
    
    // Add helper function to check if target is achievable
    private func isTargetAchievable() -> Bool {
        let numbers = gridNumbers
        
        // Check if any 2-4 numbers can sum to target
        for count in 2...4 {
            if canMakeSum(numbers: numbers, target: targetSum, maxCount: count) {
                return true
            }
        }
        return false
    }
    
    // Recursive helper to check if sum is possible
    private func canMakeSum(numbers: [Int], target: Int, maxCount: Int) -> Bool {
        func findSum(_ index: Int, _ currentSum: Int, _ count: Int) -> Bool {
            if currentSum == target && count > 0 && count <= maxCount {
                return true
            }
            if count >= maxCount || currentSum > target || index >= numbers.count {
                return false
            }
            
            // Try including current number
            if findSum(index + 1, currentSum + numbers[index], count + 1) {
                return true
            }
            // Try excluding current number
            return findSum(index + 1, currentSum, count)
        }
        
        return findSum(0, 0, 0)
    }
    
    private func endGame() {
        isActive = false
        timeRemaining = 0
        showResult = true
    }
    
    private func resetGame() {
        difficultyLevel = 1
        targetSum = Int.random(in: 15...25)
        currentSum = 0
        selectedNumbers.removeAll()
        timeRemaining = maxTime
        targetsReached = 0
        generateGridNumbers()
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        currentTimeBonus = 5.0
        currentCombo = 0
        maxCombo = 0
        lastComboTime = nil
        isActive = true
    }
    
    // Update the combo display in the view
    var comboView: some View {
        Group {
            if currentCombo > 1 {
                Text("COMBO x\(currentCombo)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.card)
                    .cornerRadius(12)
                    .transition(.scale.combined(with: .opacity))
            } else {
                EmptyView()
            }
        }
    }
}
