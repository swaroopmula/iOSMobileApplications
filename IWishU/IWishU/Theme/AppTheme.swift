import SwiftUI
import UIKit

enum AppTheme {
    // Colors
    static let primary = Color.blue
    static let secondary = Color.gray
    static let accent = Color.blue.gradient
    static let destructive = Color.red
    
    // Text Styles
    static let titleStyle = Font.title2.weight(.semibold)
    static let headlineStyle = Font.headline
    static let bodyStyle = Font.body
    static let captionStyle = Font.subheadline
        // UI Elements
    static let cornerRadius: CGFloat = 12
    static let spacing: CGFloat = 16
    static let padding: CGFloat = 16
    
    // Button Styles
    static func primaryButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(accent)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: primary.opacity(0.3), radius: 8, y: 4)
    }
    
    static func iconButton(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 20))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(primary)
    }
    
    // Card Style
    static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(padding)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
    
    // Empty State Style
    static func emptyState(
        icon: String,
        title: String,
        message: String,
        @ViewBuilder action: () -> some View
    ) -> some View {
        VStack(spacing: spacing) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(primary)
            
            Text(title)
                .font(titleStyle)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(captionStyle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            action()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Navigation Bar Style
    static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
} 
