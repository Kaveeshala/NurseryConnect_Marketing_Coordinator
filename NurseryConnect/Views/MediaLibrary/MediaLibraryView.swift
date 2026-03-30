//
//  MediaLibraryView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI
import SwiftData

struct MediaLibraryView: View {
    
    // @Query fetches ALL MediaItems from the SwiftData local database automatically
    // The View re-renders whenever this data changes
    @Query private var allItems: [MediaItem]
    
    // Access the SwiftData context to insert sample data on first launch
    @Environment(\.modelContext) private var modelContext
    
    // The ViewModel handles filtering and sorting logic
    @State private var viewModel = MediaLibraryViewModel()
    
    // Controls which item the NavigationLink will navigate to
    // (nil = no navigation active)
    @State private var selectedItem: MediaItem? = nil
    
    // 2-column grid layout — each column takes equal space
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ── FILTER BAR ──
                // Passes a binding to the ViewModel's selectedFilter
                FilterBarView(selectedFilter: $viewModel.selectedFilter)
                
                Divider()
                
                // ── PHOTO GRID OR EMPTY STATE ──
                let displayItems = viewModel.filteredItems(allItems)
                
                if displayItems.isEmpty {
                    // Empty state — shown when filter has no results
                    emptyStateView
                } else {
                    // The main scrollable photo grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayItems) { item in
                                
                                // NavigationLink wraps each card
                                // Tapping navigates to Photo Detail (Screen 2)
                                // NEW — real Screen 2
                                NavigationLink(destination: PhotoDetailView(item: item)) {
                                    MediaGridItemView(item: item)
                                }
                                // Remove the default blue tint from NavigationLink
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Media Library")
            .navigationBarTitleDisplayMode(.large)
            // Sort menu in the top-right toolbar
            .toolbar {
                // EXISTING sort menu — keep this
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortMenu
                }

                // NEW — add this second toolbar item
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: MultiSelectView(allItems: viewModel.filteredItems(allItems))) {
                        Label("Select Multiple", systemImage: "checkmark.circle")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        // onAppear: insert sample photos on first launch if database is empty
        .onAppear {
            viewModel.insertSampleData(context: modelContext)
        }
    }
    
    // ── SORT MENU (top-right button) ──
    // A Menu shows a dropdown when tapped — no extra screen needed
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    viewModel.selectedSort = option
                }) {
                    // Shows a checkmark next to the currently selected sort
                    Label(
                        option.rawValue,
                        systemImage: viewModel.selectedSort == option ? "checkmark" : ""
                    )
                }
            }
        } label: {
            // The toolbar button that opens the menu
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .font(.system(size: 16))
        }
    }
    
    // ── EMPTY STATE VIEW ──
    // Shown when filter returns no results — never just a blank screen
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No photos found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Try changing the filter above\nor check back after photos are uploaded.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// Preview — shows Screen 1 in Xcode's canvas
#Preview {
    MediaLibraryView()
        .modelContainer(for: MediaItem.self, inMemory: true)
}
