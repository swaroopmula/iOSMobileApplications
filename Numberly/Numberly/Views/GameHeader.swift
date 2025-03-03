import SwiftUI

struct GameHeader: View {
    let title: String
    let onDismiss: () -> Void
    let onInfo: () -> Void
    var additionalButton: (() -> AnyView)? = nil
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
                .frame(height: 60)
            
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.secondary)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                HStack(spacing: 16) {
                    if let additionalButton = additionalButton {
                        additionalButton()
                    }
                    
                    Button(action: onInfo) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.accent)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
} 