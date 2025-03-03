import SwiftUI

struct RemindersView: View {
    @StateObject private var viewModel = RemindersViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.reminders.isEmpty {
                    AppTheme.emptyState(
                        icon: "bell.badge",
                        title: "No Reminders",
                        message: "Add your first reminder to keep track of important dates and moments."
                    ) {
                        AppTheme.primaryButton("Add Reminder")
                            .onTapGesture {
                                viewModel.showingNewReminder = true
                            }
                            .padding(.horizontal, AppTheme.padding * 2)
                            .frame(maxWidth: 280)
                    }
                } else {
                    remindersList
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                if !viewModel.reminders.isEmpty {
                    Button {
                        viewModel.showingNewReminder = true
                    } label: {
                        AppTheme.iconButton("plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewReminder) {
                NewReminderView(viewModel: viewModel)
            }
        }
    }
    
    private var remindersList: some View {
        List {
            ForEach(viewModel.reminders.sorted(by: { $0.date < $1.date })) { reminder in
                ReminderRowView(reminder: reminder)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteReminder(reminder)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            withAnimation {
                                viewModel.toggleReminder(reminder)
                            }
                        } label: {
                            Label(
                                reminder.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                systemImage: reminder.isCompleted ? "circle" : "checkmark.circle"
                            )
                        }
                        .tint(reminder.isCompleted ? .gray : .green)
                    }
            }
        }
    }
}

struct NewReminderView: View {
    @ObservedObject var viewModel: RemindersViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var isDateValid: Bool {
        viewModel.newReminderDate > Date()
    }
    
    private var isFormValid: Bool {
        !viewModel.newReminderTitle.isEmpty && isDateValid
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Reminder Title", text: $viewModel.newReminderTitle)
                DatePicker("Date", selection: $viewModel.newReminderDate, in: Date()...)
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addReminder()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    RemindersView()
} 
