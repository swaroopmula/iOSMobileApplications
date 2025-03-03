import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PhotoGalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.fill")
                }
            
            LoveLettersView()
                .tabItem {
                    Label("Letters", systemImage: "heart.text.square.fill")
                }
            
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell.fill")
                }
        }
    }
} 
