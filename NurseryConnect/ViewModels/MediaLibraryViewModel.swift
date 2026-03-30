//
//  MediaLibraryViewModel.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import Foundation
import SwiftData
import SwiftUI

// FilterOption controls which photos are shown
enum FilterOption: String, CaseIterable {
    case all       = "All"
    case approved  = "Approved"
    case pending   = "Pending"
    case posted    = "Posted"
}

// SortOption controls how photos are ordered
enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
}

// @Observable replaces the old ObservableObject — cleaner syntax in iOS 17+
@Observable
class MediaLibraryViewModel {
    
    // Currently selected filter — changing this triggers UI update
    var selectedFilter: FilterOption = .all
    
    // Currently selected sort
    var selectedSort: SortOption = .newest
    
    // Filters and sorts the full list of items from SwiftData
    // This computed property is called by the View to get the display list
    func filteredItems(_ items: [MediaItem]) -> [MediaItem] {
        
        // Step 1: Apply the filter
        let filtered: [MediaItem]
        switch selectedFilter {
        case .all:
            filtered = items
        case .approved:
            filtered = items.filter { $0.consentStatus == .approved }
        case .pending:
            filtered = items.filter { $0.consentStatus == .pending }
        case .posted:
            filtered = items.filter { $0.isPosted }
        }
        
        // Step 2: Apply the sort
        switch selectedSort {
        case .newest:
            return filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .oldest:
            return filtered.sorted { $0.dateAdded < $1.dateAdded }
        }
    }
    
    // Inserts sample data into SwiftData on first launch
    // This replaces a real backend — gives us photos to display in the simulator
    func insertSampleData(context: ModelContext) {
        // Only insert if the library is empty
        let descriptor = FetchDescriptor<MediaItem>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        let samples: [MediaItem] = [
            MediaItem(
                imageName: "photo_arts",
                category: "Arts & Crafts",
                dateAdded: Date().addingTimeInterval(-86400 * 1),
                consentStatus: .approved,
                childCount: 3
            ),
            MediaItem(
                imageName: "photo_outdoor",
                category: "Outdoor Play",
                dateAdded: Date().addingTimeInterval(-86400 * 2),
                consentStatus: .approved,
                childCount: 5,
                isPosted: true
            ),
            MediaItem(
                imageName: "photo_reading",
                category: "Story Time",
                dateAdded: Date().addingTimeInterval(-86400 * 3),
                consentStatus: .pending,
                childCount: 2
            ),
            MediaItem(
                imageName: "photo_music",
                category: "Music & Movement",
                dateAdded: Date().addingTimeInterval(-86400 * 4),
                consentStatus: .approved,
                childCount: 4
            ),
            MediaItem(
                imageName: "photo_play",
                category: "Free Play",
                dateAdded: Date().addingTimeInterval(-86400 * 5),
                consentStatus: .pending,
                childCount: 2
            )
        ]
        
        // Insert each sample into the SwiftData context (local database)
        for item in samples {
            context.insert(item)
        }
    }
}
