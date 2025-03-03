import SwiftUI

struct Theme {
    static let accent = Color(hex: "9B4DCA")
    static let background = Color.black
    static let card = Color(white: 0.1)
    static let text = Color.white
    static let secondary = Color.gray
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = (Double((int >> 8) & 0xF) / 15.0,
                        Double((int >> 4) & 0xF) / 15.0,
                        Double(int & 0xF) / 15.0)
        case 6: // RGB (24-bit)
            (r, g, b) = (Double((int >> 16) & 0xFF) / 255.0,
                        Double((int >> 8) & 0xFF) / 255.0,
                        Double(int & 0xFF) / 255.0)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: r, green: g, blue: b)
    }
} 