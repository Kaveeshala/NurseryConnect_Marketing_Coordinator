//
//  FilterBarView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI

struct FilterBarView: View {
    
    // Two-way binding — when user taps a chip, it updates the ViewModel's selectedFilter
    @Binding var selectedFilter: FilterOption
    
    var body: some View {
        // Horizontal scroll so all chips are accessible on small screens
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                
                // Loop through every FilterOption case and create a chip for each
                ForEach(FilterOption.allCases, id: \.self) { option in
                    FilterChip(
                        title: option.rawValue,
                        isSelected: selectedFilter == option
                    ) {
                        // When tapped, update the selected filter with animation
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = option
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// A single chip button — extracted to keep FilterBarView clean
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // Selected chip: filled teal background; unselected: outline only
                .background(
                    Capsule()
                        .fill(isSelected ? Color.teal : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.teal : Color.gray.opacity(0.4), lineWidth: 1)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        // Smooth colour transition when selection changes
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    FilterBarView(selectedFilter: .constant(.all))
}
