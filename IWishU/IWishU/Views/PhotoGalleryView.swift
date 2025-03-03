import SwiftUI
import PhotosUI
import UIKit

struct PhotoGalleryView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [ImageItem] = []
    @State private var isLoading = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var selectedImageForAction: ImageItem? = nil
    @State private var isSelectionMode = false
    @State private var selectedImageIds: Set<UUID> = []
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    private var gridItemSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 12
        let horizontalPadding: CGFloat = 16
        return (screenWidth - (2 * spacing) - (2 * horizontalPadding)) / 3
    }
    
    var body: some View {
        let columns = [
            GridItem(.fixed(gridItemSize), spacing: 12),
            GridItem(.fixed(gridItemSize), spacing: 12),
            GridItem(.fixed(gridItemSize), spacing: 12)
        ]
        
        NavigationView {
            ZStack {
                // Background
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea()
                
                // Blurred Background
                if let firstImage = images.first?.image {
                    Image(uiImage: firstImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: 60)
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            Color(colorScheme == .dark ? .black : .white)
                                .opacity(0.7)
                                .ignoresSafeArea()
                        }
                        .transition(.opacity)
                }
                
                // Main Content
                Group {
                    if images.isEmpty {
                        emptyStateView
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        ScrollView(showsIndicators: false) {
                            photosGrid(columns: columns)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.smooth, value: images.isEmpty)
                
                // Loading Overlay
                if isLoading {
                    loadingOverlay
                        .transition(.opacity)
                }
            }
            .navigationTitle(isSelectionMode ? "\(selectedImageIds.count) Selected" : "Memories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            withAnimation {
                                isSelectionMode = false
                                selectedImageIds.removeAll()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if isSelectionMode {
                            if !selectedImageIds.isEmpty {
                                Button(role: .destructive) {
                                    showingDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        } else {
                            if !images.isEmpty {
                                PhotosPicker(selection: $selectedItems, matching: .images) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                handleNewPhotos(newItems)
            }
            .alert("Delete Photos?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedImages()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedImageIds.count) photo\(selectedImageIds.count == 1 ? "" : "s")?")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                    
                    Text("No Photos Yet")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Add photos to start your collection")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Text("Add Photos")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 200)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Adding Photos...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
                    .shadow(radius: 20)
            )
        }
    }
    
    private func photosGrid(columns: [GridItem]) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(images) { item in
                PhotoTile(
                    item: item,
                    isSelected: selectedImageIds.contains(item.id),
                    animation: animation,
                    showingShareSheet: $showingShareSheet,
                    showingDeleteAlert: $showingDeleteAlert,
                    isSelectionMode: $isSelectionMode,
                    selectedImageIds: $selectedImageIds,
                    onTap: {
                        if isSelectionMode {
                            toggleSelection(item)
                        }
                    },
                    onLongPress: {
                        selectedImageForAction = item
                        if !isSelectionMode {
                            withAnimation {
                                isSelectionMode = true
                                selectedImageIds.insert(item.id)
                            }
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
                )
            }
        }
    }
    
    private func handleNewPhotos(_ items: [PhotosPickerItem]) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.3)) {
                            images.append(ImageItem(image: image))
                        }
                    }
                }
            }
            selectedItems.removeAll()
        }
    }
    
    private func toggleSelection(_ item: ImageItem) {
        withAnimation {
            if selectedImageIds.contains(item.id) {
                selectedImageIds.remove(item.id)
                if selectedImageIds.isEmpty {
                    isSelectionMode = false
                }
            } else {
                selectedImageIds.insert(item.id)
            }
        }
    }
    
    private func deleteSelectedImages() {
        withAnimation(.smooth(duration: 0.3)) {
            images.removeAll { selectedImageIds.contains($0.id) }
            selectedImageIds.removeAll()
            isSelectionMode = false
        }
    }
}

struct PhotoTile: View {
    let item: ImageItem
    let isSelected: Bool
    let animation: Namespace.ID
    @Binding var showingShareSheet: Bool
    @Binding var showingDeleteAlert: Bool
    @Binding var isSelectionMode: Bool
    @Binding var selectedImageIds: Set<UUID>
    let onTap: () -> Void
    let onLongPress: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width / 3 - 20, height: UIScreen.main.bounds.width / 3 - 20)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                .matchedGeometryEffect(id: item.id, in: animation)
                .overlay {
                    if isSelectionMode {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(isSelected ? 0.3 : 0))
                                .animation(.easeInOut, value: isSelected)
                            
                            if isSelected {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.blue, lineWidth: 3)
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .background(
                                            Circle()
                                                .fill(isSelected ? Color.blue : Color.clear)
                                        )
                                        .frame(width: 24, height: 24)
                                        .overlay {
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(8)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .contextMenu {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress()
                        showingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress()
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation {
                            isSelectionMode = true
                            selectedImageIds.insert(item.id)
                        }
                    } label: {
                        Label("Select Multiple", systemImage: "checkmark.circle")
                    }
                }
                .onTapGesture(perform: onTap)
                .onLongPressGesture {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onLongPress()
                }
        }
    }
}

struct ImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 


