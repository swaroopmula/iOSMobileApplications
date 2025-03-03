import SwiftUI

struct AnimationConstants {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let easeOut = Animation.easeOut(duration: 0.2)
}


struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Choose a Game")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.text)
                    
                    NavigationLink {
                        BullsAndCowsGame()
                            .navigationBarBackButtonHidden()
                    } label: {
                        GameButton(
                            title: "Bulls & Cows",
                            subtitle: "Guess the 4-digit number",
                            icon: "123.rectangle.fill"
                        )
                    }
                    
                    NavigationLink {
                        HigherLowerGame()
                            .navigationBarBackButtonHidden()
                    } label: {
                        GameButton(
                            title: "Higher Lower",
                            subtitle: "Find the number between 1-100",
                            icon: "arrow.up.arrow.down"
                        )
                    }
                    
                    NavigationLink {
                        SumRushGame()
                            .navigationBarBackButtonHidden()
                    } label: {
                        GameButton(
                            title: "Sum Rush",
                            subtitle: "Race against time to hit the target",
                            icon: "timer"
                        )
                    }
                    
                    NavigationLink {
                        SudokuGame()
                            .navigationBarBackButtonHidden()
                    } label: {
                        GameButton(
                            title: "Sudoku",
                            subtitle: "Fill the grid with numbers",
                            icon: "grid"
                        )
                    }
                    
                    NavigationLink {
                        NumTacShiftGame()
                            .navigationBarBackButtonHidden()
                    } label: {
                        GameButton(
                            title: "NumTac Shift",
                            subtitle: "Dynamic 2-player grid battle",
                            icon: "number.square.fill"
                        )
                    }
                }
                .padding(30)
            }
            .navigationBarHidden(true)
        }
    }
}

// Helper view for game selection buttons
private struct GameButton: View {
    let title: String
    let subtitle: String
    let icon: String
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.accent)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.text)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.secondary)
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.98 : 1)
        .scaleEffect(isHovered ? 1.02 : 1)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct NumberKey: View {
    let text: String?
    let systemImage: String?
    var color: Color = Theme.accent
    let isPressed: Bool
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if let text = text {
                    Text(text)
                        .font(.title2)
                        .accessibilityLabel("Number \(text)")
                        .accessibilityHint("Tap to enter number \(text)")
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .accessibilityLabel(
                            systemImage == "delete.left" ? "Delete" :
                            systemImage == "checkmark.circle.fill" ? "Submit" : ""
                        )
                        .accessibilityHint(
                            systemImage == "delete.left" ? "Tap to delete last digit" :
                            systemImage == "checkmark.circle.fill" ? "Tap to submit your guess" : ""
                        )
                }
            }
            .foregroundColor(disabled ? Theme.secondary : Theme.text)
            .frame(width: 60, height: 60)
            .background(
                Theme.card
                    .overlay(
                        Theme.accent.opacity(isPressed ? 0.2 : 0)
                    )
            )
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .disabled(disabled)
    }
}

// Make GameMode conform to Identifiable for fullScreenCover
extension GameMode: Identifiable {
    var id: Self { self }
}


#Preview {
    ContentView()
}
