import SwiftUI
import Foundation

enum GameMode: String, CaseIterable {
    case higherLower = "Higher or Lower"
    case bullsAndCows = "Bulls & Cows"
    case sumRush = "Sum Rush"
    case sudoku = "Sudoku"
    case numTacShift = "NumTac Shift"
    
    var icon: String {
        switch self {
        case .higherLower: return "arrow.up.arrow.down"
        case .bullsAndCows: return "123.rectangle.fill"
        case .sumRush: return "timer"
        case .sudoku: return "grid"
        case .numTacShift: return "number.square.fill"
        }
    }
    
    var description: String {
        switch self {
        case .higherLower: return "Guess the secret number"
        case .bullsAndCows: return "Crack the number code"
        case .sumRush: return "Race against time"
        case .sudoku: return "Fill the grid with numbers"
        case .numTacShift: return "Dynamic 2-player grid battle"
        }
    }
}

enum NumberStatus {
    case normal
    case confirmed
    case wrong
    
    func next() -> NumberStatus {
        switch self {
        case .normal: return .confirmed
        case .confirmed: return .wrong
        case .wrong: return .normal
        }
    }
    
    var color: Color {
        switch self {
        case .normal: return Theme.secondary
        case .confirmed: return .green
        case .wrong: return .red
        }
    }
} 
