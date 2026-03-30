//
//  MediaGridItemView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI

struct MediaGridItemView: View {
    
    // The MediaItem data this card displays
    let item: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // ── PHOTO THUMBNAIL ──
            ZStack(alignment: .topTrailing) {
                
                // The actual image loaded from Assets.xcassets
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()               // fills the frame, may crop
                    .frame(height: 140)
                    .clipped()                    // clips overflow from scaledToFill
                
                // "Already Posted" overlay — semi-transparent banner at top
                if item.isPosted {
                    Text("Posted")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .padding(6)
                }
                
                // Consent badge pinned to the bottom-left of the image
                VStack {
                    Spacer()
                    HStack {
                        ConsentBadgeView(status: item.consentStatus)
                            .padding(6)
                        Spacer()
                    }
                }
            }
            .frame(height: 140)
            
            // ── CARD INFO SECTION ──
            VStack(alignment: .leading, spacing: 4) {
                
                // Category label
                Text(item.category)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Date added
                Text(item.dateAdded, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                // Child count (no names — GDPR compliant)
                HStack(spacing: 3) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(item.childCount) \(item.childCount == 1 ? "child" : "children")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        // Card container styling
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        // Dim the card if already posted — subtle visual signal
        .opacity(item.isPosted ? 0.7 : 1.0)
    }
}
