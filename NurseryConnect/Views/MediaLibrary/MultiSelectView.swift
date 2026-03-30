//
//  MultiSelectView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI
import SwiftData

struct MultiSelectView: View {

    // All items passed in from Screen 1 (the already-filtered list)
    let allItems: [MediaItem]

    // Tracks which item IDs the user has selected
    // Using a Set so we can check membership in O(1)
    @State private var selectedIDs: Set<UUID> = []

    // Controls navigation to Create Post screen
    @State private var navigateToCreatePost = false

    // 3-column grid — tighter than Screen 1's 2-column to show more photos
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    // Computed: only the approved items (pending items can't be posted)
    // This filters out non-approved photos automatically
    var approvedItems: [MediaItem] {
        allItems.filter { $0.consentStatus == .approved }
    }

    // Computed: the actual selected MediaItem objects (not just IDs)
    var selectedItems: [MediaItem] {
        approvedItems.filter { selectedIDs.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── TOP INFO BANNER ──
            infoBanner

            // ── PHOTO GRID ──
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(approvedItems) { item in
                        SelectablePhotoCell(
                            item: item,
                            isSelected: selectedIDs.contains(item.id)
                        ) {
                            // Toggle selection on tap with animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedIDs.contains(item.id) {
                                    selectedIDs.remove(item.id)
                                } else {
                                    // Limit to 10 photos max per post
                                    if selectedIDs.count < 10 {
                                        selectedIDs.insert(item.id)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
                // Extra bottom padding so the sticky button doesn't hide the last row
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)
        }
        // ── STICKY BOTTOM BUTTON ──
        // Overlaid at the bottom — always visible while scrolling
        .overlay(alignment: .bottom) {
            bottomBar
        }
        .navigationTitle("Select Photos")
        .navigationBarTitleDisplayMode(.inline)
        // "Select All" and "Clear" toolbar buttons
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarMenu
            }
        }
        // Navigate to Create Post when button is tapped
        .navigationDestination(isPresented: $navigateToCreatePost) {
            CreatePostView(selectedItems: selectedItems)
        }

    }

    // ── INFO BANNER ──
    // Explains to the user what they're doing and why only approved photos show
    private var infoBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.teal)
                .font(.system(size: 16))

            Text("Only GDPR-approved photos are shown. Select up to 10 for your post.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }

    // ── BOTTOM STICKY BAR ──
    // Shows count of selected photos + the "Create Post" button
    private var bottomBar: some View {
        VStack(spacing: 0) {
            // Thin divider line above the bar
            Divider()

            HStack(spacing: 16) {

                // Left side: selection count
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedIDs.count) selected")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(selectedIDs.count == 0
                         ? "Tap photos to select"
                         : "Max 10 photos per post")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Right side: Create Post button
                // Disabled until at least 1 photo is selected
                Button(action: {
                    navigateToCreatePost = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Create Post")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedIDs.isEmpty ? Color.gray : Color.teal)
                    )
                }
                .disabled(selectedIDs.isEmpty)
                // Animate colour change as items are selected/deselected
                .animation(.easeInOut(duration: 0.2), value: selectedIDs.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
        }
    }

    // ── TOOLBAR MENU ──
    // "Select All" and "Clear Selection" as a dropdown
    private var toolbarMenu: some View {
        Menu {
            Button("Select All") {
                withAnimation {
                    // Select all approved items (up to 10)
                    let ids = approvedItems.prefix(10).map { $0.id }
                    selectedIDs = Set(ids)
                }
            }

            Button("Clear Selection", role: .destructive) {
                withAnimation {
                    selectedIDs.removeAll()
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
        }
    }
}

// ── SELECTABLE PHOTO CELL ──
// A single photo tile in the 3-column grid.
// Shows a checkmark overlay and teal border when selected.
struct SelectablePhotoCell: View {
    let item: MediaItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {

                // The photo image
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .clipped()
                    .cornerRadius(8)

                // Dark overlay when selected — makes photo look "chosen"
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.teal.opacity(0.25))
                }

                // Selection indicator: teal checkmark circle (top-right corner)
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.teal : Color.black.opacity(0.4))
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        // Empty circle when not selected
                        Circle()
                            .stroke(Color.white, lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(6)
            }
            // Teal border ring when selected
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 2.5)
            )
        }
        .buttonStyle(.plain)
        // Slight scale bounce when tapped — feels responsive
        .scaleEffect(isSelected ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

// Preview
#Preview {
    NavigationStack {
        MultiSelectView(allItems: [
            MediaItem(imageName: "photo_arts", category: "Arts & Crafts",
                      consentStatus: .approved, childCount: 3),
            MediaItem(imageName: "photo_outdoor", category: "Outdoor Play",
                      consentStatus: .approved, childCount: 5),
            MediaItem(imageName: "photo_reading", category: "Story Time",
                      consentStatus: .pending, childCount: 2),
            MediaItem(imageName: "photo_music", category: "Music",
                      consentStatus: .approved, childCount: 4)
        ])
    }
    .modelContainer(for: MediaItem.self, inMemory: true)
}
