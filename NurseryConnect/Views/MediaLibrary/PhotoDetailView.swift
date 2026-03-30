//
//  PhotoDetailView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI
import SwiftData

struct PhotoDetailView: View {

    // The MediaItem passed in from Screen 1 when user taps a photo card
    let item: MediaItem

    // Controls whether the "Use in Post" button navigates forward
    // (We'll wire this to CreatePostView in Screen 4)
    @State private var navigateToCreatePost = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── SECTION 1: FULL PHOTO ──
                photoSection

                // ── SECTION 2: GDPR COMPLIANCE BANNER ──
                gdprBanner

                // ── SECTION 3: METADATA DETAILS ──
                metadataSection

                // ── SECTION 4: ACTION BUTTONS ──
                actionSection
            }
        }
        // Navigation bar title — shows the category name
        .navigationTitle(item.category)
        .navigationBarTitleDisplayMode(.inline)
        // This makes the navigation bar transparent so photo bleeds to top
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // ── PHOTO SECTION ──
    // Full-width photo at the top — same image loaded from Assets
    private var photoSection: some View {
        ZStack(alignment: .bottomLeading) {

            // The photo itself — fills the full width, fixed height
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()

            // Gradient overlay at the bottom so badge is readable on any photo
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)

            // Consent badge pinned to bottom-left of the photo
            HStack(spacing: 8) {
                ConsentBadgeView(status: item.consentStatus)

                // "Already Posted" tag shown if photo was used before
                if item.isPosted {
                    Text("Already Posted")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .foregroundColor(.white)
                }
            }
            .padding(16)
        }
    }

    // ── GDPR COMPLIANCE BANNER ──
    // This green banner reassures the user the photo is safe to use publicly
    // It's a key feature for the assignment's GDPR compliance angle
    private var gdprBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("GDPR Compliant")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text("All faces have been blurred. No child identifiable information is visible.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.green.opacity(0.08))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.green.opacity(0.2)),
            alignment: .bottom
        )
    }

    // ── METADATA SECTION ──
    // Shows all the details about this photo in a clean list
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Section header
            Text("Photo Details")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 12)

            // Each metadata row is a reusable component defined below
            VStack(spacing: 0) {

                MetadataRowView(
                    icon: "tag.fill",
                    label: "Category",
                    value: item.category
                )

                Divider().padding(.leading, 56)

                MetadataRowView(
                    icon: "calendar",
                    label: "Date Added",
                    value: item.dateAdded.formatted(date: .long, time: .omitted)
                )

                Divider().padding(.leading, 56)

                MetadataRowView(
                    icon: "person.2.fill",
                    label: "Children in Photo",
                    // Shows count only — never names (GDPR data minimisation)
                    value: "\(item.childCount) \(item.childCount == 1 ? "child" : "children") (names not stored)"
                )

                Divider().padding(.leading, 56)

                MetadataRowView(
                    icon: item.consentStatus == .approved ? "checkmark.seal.fill" : "clock.fill",
                    label: "Consent Status",
                    value: item.consentStatus.rawValue,
                    // Colour the value text based on status
                    valueColor: item.consentStatus == .approved ? .green : .orange
                )

                Divider().padding(.leading, 56)

                MetadataRowView(
                    icon: "paperplane.fill",
                    label: "Post Status",
                    value: item.isPosted ? "Previously posted" : "Not yet posted",
                    valueColor: item.isPosted ? .secondary : .primary
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }

    // ── ACTION BUTTONS SECTION ──
    // Primary: "Use in Post" — only enabled if consent is approved
    // Secondary: "Mark as Reviewed" — only shown if status is pending
    private var actionSection: some View {
        VStack(spacing: 12) {

            // PRIMARY BUTTON — Use in Post
            // Disabled and greyed out if consent is not approved yet
            NavigationLink(destination: Text("Create Post Screen — Coming Soon")) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text(item.consentStatus == .approved ? "Use in Post" : "Consent Required to Post")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        // Teal when approved, grey when pending
                        .fill(item.consentStatus == .approved ? Color.teal : Color.gray)
                )
            }
            // Disable tapping if consent is pending
            .disabled(item.consentStatus != .approved)

            // SECONDARY BUTTON — only shown for pending photos
            if item.consentStatus == .pending {
                Button(action: {
                    // In a real app this would call an API
                    // For the MVP we just show what this button would do
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Mark as Reviewed")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.teal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.teal, lineWidth: 1.5)
                    )
                }
            }

            // Small note reminding user about GDPR
            Text("Only GDPR-approved images with blurred faces may be posted to social media.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(20)
    }
}

// ── METADATA ROW COMPONENT ──
// A reusable row: [icon] [label]  [value]
// Used 5 times in the metadata section above
struct MetadataRowView: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary  // optional — defaults to primary text colour

    var body: some View {
        HStack(spacing: 16) {

            // Left: icon in a fixed-size frame so all rows align perfectly
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.teal)
                .frame(width: 24)

            // Middle: label
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Spacer()

            // Right: value — colour changes based on context
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// Preview — lets you see the screen in Xcode canvas
#Preview {
    NavigationStack {
        PhotoDetailView(item: MediaItem(
            imageName: "photo_arts",
            category: "Arts & Crafts",
            dateAdded: Date(),
            consentStatus: .approved,
            childCount: 3
        ))
    }
    .modelContainer(for: MediaItem.self, inMemory: true)
}
