import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .strikethrough(reminder.isCompleted)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                
                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(reminder.isCompleted ? .green : .gray)
                .font(.title3)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ReminderRowView(reminder: Reminder(
        title: "Sample Reminder",
        date: Date(),
        isCompleted: false
    ))
    .padding()
} 