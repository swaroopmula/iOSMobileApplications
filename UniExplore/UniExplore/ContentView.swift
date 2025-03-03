//
//  ContentView.swift
//  UniExplore
//
//  Created by Swaroop Mula on 2/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UniversityViewModel()
    @State private var showingFilters = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search and Filter Bar
                    HStack {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search universities...", text: $viewModel.searchText)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    isSearchFocused = false
                                }
                            
                            if !viewModel.searchText.isEmpty {
                                Button {
                                    viewModel.searchText = ""
                                    isSearchFocused = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        
                        // Filter Button
                        Button {
                            isSearchFocused = false
                            showingFilters.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .overlay {
                                    if viewModel.hasActiveFilters {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 8, y: -8)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Active Filters View
                    if viewModel.hasActiveFilters {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if viewModel.selectedCountry != "All Countries" {
                                    FilterChip(text: viewModel.selectedCountry) {
                                        viewModel.selectedCountry = "All Countries"
                                    }
                                }
                                
                                if viewModel.selectedState != "All States" {
                                    FilterChip(text: viewModel.selectedState) {
                                        viewModel.selectedState = "All States"
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Results Count and Sort
                    HStack {
                        Text("\(viewModel.filteredUniversities().count) universities found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        
                        Menu {
                            Button {
                                viewModel.sortOrder = .nameAsc
                            } label: {
                                Label("Name (A-Z)", systemImage: "arrow.up")
                            }
                            
                            Button {
                                viewModel.sortOrder = .nameDesc
                            } label: {
                                Label("Name (Z-A)", systemImage: "arrow.down")
                            }
                            
                            Button {
                                viewModel.sortOrder = .country
                            } label: {
                                Label("Country", systemImage: "globe")
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Universities List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredUniversities()) { university in
                                UniversityCard(university: university)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        viewModel.loadUniversities()
                    }
                }
            }
            .navigationTitle("Universities")
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isSearchFocused = false
                    }
                }
            }
        }
    }
}

// Enhanced FilterChip View
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Filter View
struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UniversityViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Country")) {
                    Picker("Select Country", selection: $viewModel.selectedCountry) {
                        ForEach(viewModel.availableCountries, id: \.self) { country in
                            Text(country)
                        }
                    }
                    .onChange(of: viewModel.selectedCountry) { _ in
                        viewModel.updateAvailableStates()
                    }
                }
                
                if viewModel.selectedCountry != "All Countries" {
                    Section(header: Text("State/Province")) {
                        Picker("Select State", selection: $viewModel.selectedState) {
                            ForEach(viewModel.availableStates, id: \.self) { state in
                                Text(state)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
