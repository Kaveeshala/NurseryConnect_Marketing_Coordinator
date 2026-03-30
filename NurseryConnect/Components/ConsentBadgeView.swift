//
//  ConsentBadgeView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI

struct ConsentBadgeView: View {
    
    // The badge receives a ConsentStatus and displays itself accordingly
    let status: ConsentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            // SF Symbol icon — checkmark for approved, clock for pending
            Image(systemName: status.icon)
                .font(.system(size: 9, weight: .semibold))
            
            // The status label text
            Text(status.rawValue)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        // Colour changes based on status
        .foregroundColor(status == .approved ? .white : .white)
        .background(
            Capsule()
                .fill(status == .approved ? Color.green : Color.orange)
        )
    }
}

// Preview lets you see the badge in Xcode's canvas without running the app
#Preview {
    HStack {
        ConsentBadgeView(status: .approved)
        ConsentBadgeView(status: .pending)
    }
    .padding()
}
