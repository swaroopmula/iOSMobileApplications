import Foundation
import SwiftUI

@MainActor
class RemindersViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var showingNewReminder = false
    @Published var newReminderTitle = ""
    @Published var newReminderDate = Date()
    
    private let saveKey = "savedReminders"
    
    init() {
        loadReminders()
    }
    
    func addReminder() {
        let reminder = Reminder(
            title: newReminderTitle,
            date: newReminderDate
        )
        reminders.append(reminder)
        saveReminders()
        resetNewReminderForm()
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
            saveReminders()
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    private func resetNewReminderForm() {
        newReminderTitle = ""
        newReminderDate = Date()
        showingNewReminder = false
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
} 