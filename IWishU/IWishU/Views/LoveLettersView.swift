import SwiftUI

struct LoveLettersView: View {
    @State private var letters: [Letter] = []
    @State private var showingNewLetter = false
    @State private var showingDeleteAlert = false
    @State private var letterToDelete: Letter?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea()
                
                if letters.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(letters) { letter in
                                LetterCard(letter: letter) {
                                    letterToDelete = letter
                                    showingDeleteAlert = true
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Love Letters")
            .toolbar {
                if !letters.isEmpty {
                    Button {
                        showingNewLetter = true
                    } label: {
                        AppTheme.iconButton("plus.circle.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showingNewLetter) {
                NewLetterView(letters: $letters)
            }
            .alert("Delete Letter", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let letter = letterToDelete {
                        deleteLetter(letter)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this letter?")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 70))
                .foregroundStyle(.pink.gradient)
            
            Text("No Letters Yet")
                .font(.title2.bold())
            
            Text("Write your first love letter")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingNewLetter = true
            } label: {
                Text("Write Letter")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 200)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.pink.gradient)
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.top, 10)
        }
        .padding()
    }
    
    private func deleteLetter(_ letter: Letter) {
        withAnimation(.spring(response: 0.3)) {
            letters.removeAll { $0.id == letter.id }
        }
    }
}

struct LetterCard: View {
    let letter: Letter
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(letter.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(letter.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(letter.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                showingDetail = true
            } label: {
                Label("Read", systemImage: "book")
            }
        }
        .sheet(isPresented: $showingDetail) {
            LetterDetailView(letter: letter)
        }
    }
}

struct NewLetterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var letters: [Letter]
    @State private var title = ""
    @State private var content = ""
    @State private var author = ""
    @State private var showingDiscardAlert = false
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) private var colorScheme
    
    enum Field {
        case title, content, author
    }
    
    var hasUnsavedChanges: Bool {
        !title.isEmpty || !content.isEmpty || !author.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        // Date line
                        HStack {
                            Spacer()
                            Text(Date.now.formatted(date: .long, time: .omitted))
                                .font(.system(.subheadline, design: .serif))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 10)
                        
                        // Title
                        TextField("Dear...", text: $title)
                            .font(.system(.title3, design: .serif))
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .title)
                            .padding(.bottom, 10)
                        
                        // Decorative line
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                        
                        // Content
                        TextEditor(text: $content)
                            .font(.system(.body, design: .serif))
                            .frame(minHeight: 400)
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                            .focused($focusedField, equals: .content)
                        
                        // Signature
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("With love,")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(.secondary)
                                .italic()
                            TextField("Your name", text: $author)
                                .font(.system(.title3, design: .serif))
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .author)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(30)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 2)
                    )
                    .overlay {
                        Rectangle()
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGray6))
            .navigationTitle("New Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveLetter()
                    } label: {
                        Text("Save")
                            .fontWeight(.medium)
                    }
                    .disabled(title.isEmpty || content.isEmpty || author.isEmpty)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to discard your unsaved letter?")
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
            .onAppear {
                focusedField = .title
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    private func saveLetter() {
        let letter = Letter(
            title: title,
            content: content,
            date: Date(),
            author: author
        )
        
        withAnimation {
            letters.insert(letter, at: 0)
        }
        dismiss()
    }
}

struct LetterDetailView: View {
    let letter: Letter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Paper content
                VStack(spacing: 24) {
                    // Date
                    Text(letter.date.formatted(date: .long, time: .omitted))
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Title
                    Text(letter.title)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    // Decorative line
                    HStack {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    
                    // Content
                    Text(letter.content)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 40)
                    
                    // Signature
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("With love,")
                            .font(.system(.body, design: .serif))
                            .italic()
                        Text(letter.author)
                            .font(.system(.title3, design: .serif))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                }
                .padding(32)
                .background(
                    Color(colorScheme == .dark ? .systemGray6 : .white)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 2)
                )
                .padding(.top, 20)
            }
            .padding(.horizontal)
        }
        .background(Color(colorScheme == .dark ? .black : .systemGray6))
        .ignoresSafeArea()
        .interactiveDismissDisabled(false)
    }
}

struct Letter: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let date: Date
    let author: String
} 
