import SwiftUI

struct NumberPad: View {
    let onNumber: (String) -> Void
    let onDelete: () -> Void
    let onSubmit: () -> Void
    let submitDisabled: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { row in
                HStack(spacing: 12) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        NumberButton(title: "\(number)") {
                            onNumber("\(number)")
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                NumberButton(title: "⌫", color: .red) {
                    onDelete()
                }
                
                NumberButton(title: "0") {
                    onNumber("0")
                }
                
                NumberButton(title: "✓", color: Theme.accent, disabled: submitDisabled) {
                    onSubmit()
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct NumberButton: View {
    let title: String
    var color: Color = Theme.text
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(disabled ? color.opacity(0.3) : color)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Theme.card)
                .cornerRadius(12)
        }
        .disabled(disabled)
    }
}

struct NumberCheckList: View {
    @Binding var numberStatuses: [String: NumberStatus]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...9, id: \.self) { number in
                let numStr = "\(number)"
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        let currentStatus = numberStatuses[numStr] ?? .normal
                        numberStatuses[numStr] = currentStatus.next()
                    }
                } label: {
                    Text(numStr)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(numberStatuses[numStr]?.color ?? Theme.secondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(numberStatuses[numStr]?.color ?? Theme.secondary, lineWidth: 1)
                        )
                        .scaleEffect(numberStatuses[numStr] != .normal ? 1.1 : 1)
                }
            }
        }
        .padding(.horizontal)
    }
} 