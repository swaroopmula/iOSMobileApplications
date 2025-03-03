import SwiftUI

struct GalleryView: View {
    @State private var images: [UIImage] = []
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Memories")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                if images.isEmpty {
                    emptyStateView
                } else {
                   
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(images.indices, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipped()
                                .onTapGesture {
    
                                }
                        }
                    }
                    .padding()
                    .padding(.top, 50)
                }
            }
            .navigationTitle("Gallery")
            .toolbar {
                Button {
                    showingImagePicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                // Your image picker view here
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo")
                .font(.system(size: 70))
                .foregroundStyle(.gray)
            
            Text("No Images Yet")
                .font(.title2.bold())
            
            Text("Add your first image to the gallery.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingImagePicker = true
            } label: {
                Text("Add Image")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 200)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .padding(.top, 10)
        }
        .padding()
    }
} 
