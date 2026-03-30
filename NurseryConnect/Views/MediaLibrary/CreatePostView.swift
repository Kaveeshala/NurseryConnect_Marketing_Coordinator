//
//  CreatePostView.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import SwiftUI
import SwiftData

struct CreatePostView: View {

    // The selected photos passed in from Screen 2 or Screen 3
    let selectedItems: [MediaItem]

    // SwiftData context — used to save the post
    @Environment(\.modelContext) private var modelContext

    // Dismiss the view after successful post creation
    @Environment(\.dismiss) private var dismiss

    // ── FORM STATE ──
    @State private var caption: String = ""
    @State private var facebookSelected: Bool = true
    @State private var instagramSelected: Bool = false
    @State private var scheduleForLater: Bool = false
    @State private var scheduledDate: Date = Date().addingTimeInterval(3600) // 1hr from now
    @State private var gdprConfirmed: Bool = false

    // ── UI STATE ──
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var navigateToConfirmation: Bool = false
    @State private var savedPost: ScheduledPost? = nil

    // Character limit — matches Instagram's real limit
    let captionLimit = 2200

    // Computed: whether the form is valid enough to submit
    var canSubmit: Bool {
        !caption.trimmingCharacters(in: .whitespaces).isEmpty
        && (facebookSelected || instagramSelected)
        && gdprConfirmed
        && (!scheduleForLater || scheduledDate > Date())
    }

    var selectedPlatforms: [String] {
        var p: [String] = []
        if facebookSelected  { p.append("facebook") }
        if instagramSelected { p.append("instagram") }
        return p
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── SECTION 1: PHOTO PREVIEW STRIP ──
                photoPreviewSection

                // ── SECTION 2: CAPTION EDITOR ──
                captionSection

                // ── SECTION 3: PLATFORM SELECTOR ──
                platformSection

                // ── SECTION 4: SCHEDULE PICKER ──
                scheduleSection

                // ── SECTION 5: GDPR CONFIRMATION ──
                gdprSection

                // ── SECTION 6: SUBMIT BUTTON ──
                submitSection
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        // Validation alert — shown when user taps submit with missing fields
        .alert("Please complete the form", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        // Navigate to Screen 5 (Confirmation) after saving
        .navigationDestination(isPresented: $navigateToConfirmation) {
            if let post = savedPost {
                PostConfirmationView(post: post)
            }
        }
    }

    // ── PHOTO PREVIEW STRIP ──
    // Horizontal scroll of the selected photos — shows user what they're posting
    private var photoPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Label("Selected Photos (\(selectedItems.count))", systemImage: "photo.on.rectangle")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedItems) { item in
                        ZStack(alignment: .bottomLeading) {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)

                            // Lock icon — reminds user faces are blurred
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(4)
                        }
                    }
                }
            }
        }
    }

    // ── CAPTION EDITOR ──
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Label("Caption", systemImage: "text.alignleft")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                // Live character counter — turns red near limit
                Text("\(caption.count)/\(captionLimit)")
                    .font(.system(size: 12))
                    .foregroundColor(caption.count > captionLimit - 100 ? .red : .secondary)
            }

            TextEditor(text: $caption)
                .frame(minHeight: 120)
                .padding(12)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                // Enforce character limit
                .onChange(of: caption) { _, newValue in
                    if newValue.count > captionLimit {
                        caption = String(newValue.prefix(captionLimit))
                    }
                }

            // Placeholder shown when caption is empty
            if caption.isEmpty {
                Text("Write your post caption here...")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.leading, 16)
                    .padding(.top, -100)
                    .allowsHitTesting(false)
            }
        }
    }

    // ── PLATFORM SELECTOR ──
    private var platformSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Label("Platforms", systemImage: "square.grid.2x2")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {

                // Facebook toggle chip
                PlatformChip(
                    name: "Facebook",
                    icon: "f.circle.fill",
                    color: Color(red: 0.23, green: 0.35, blue: 0.6),
                    isSelected: facebookSelected
                ) {
                    facebookSelected.toggle()
                }

                // Instagram toggle chip
                PlatformChip(
                    name: "Instagram",
                    icon: "camera.circle.fill",
                    color: Color(red: 0.8, green: 0.2, blue: 0.4),
                    isSelected: instagramSelected
                ) {
                    instagramSelected.toggle()
                }
            }

            // Warning shown if neither platform is selected
            if !facebookSelected && !instagramSelected {
                Label("Select at least one platform", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
        }
    }

    // ── SCHEDULE PICKER ──
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Label("Scheduling", systemImage: "calendar.clock")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            // Toggle: Post Now vs Schedule for Later
            HStack(spacing: 0) {
                ScheduleToggleButton(
                    title: "Post Now",
                    icon: "bolt.fill",
                    isSelected: !scheduleForLater
                ) {
                    scheduleForLater = false
                }
                ScheduleToggleButton(
                    title: "Schedule",
                    icon: "clock.fill",
                    isSelected: scheduleForLater
                ) {
                    scheduleForLater = true
                }
            }
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)

            // DatePicker only shown when "Schedule" is selected
            if scheduleForLater {
                DatePicker(
                    "Scheduled date & time",
                    selection: $scheduledDate,
                    in: Date()...,   // Cannot schedule in the past
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .padding(12)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
            }
        }
    }

    // ── GDPR CONFIRMATION ──
    // This is legally required — the checkbox is the coordinator's digital signature
    private var gdprSection: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                gdprConfirmed.toggle()
            }
        }) {
            HStack(alignment: .top, spacing: 12) {

                // Animated checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(gdprConfirmed ? Color.teal : Color(.systemGroupedBackground))
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(gdprConfirmed ? Color.teal : Color(.separator), lineWidth: 1.5)
                        )

                    if gdprConfirmed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gdprConfirmed)

                // Legal statement text
                VStack(alignment: .leading, spacing: 4) {
                    Text("GDPR Confirmation")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("I confirm that all faces in these images have been blurred, no child's personal information is visible, and all images have received consent approval for social media use.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gdprConfirmed ? Color.teal.opacity(0.06) : Color(.systemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gdprConfirmed ? Color.teal.opacity(0.3) : Color(.separator), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // ── SUBMIT BUTTON ──
    private var submitSection: some View {
        VStack(spacing: 12) {

            Button(action: submitPost) {
                HStack {
                    Image(systemName: scheduleForLater ? "clock.fill" : "paperplane.fill")
                    Text(scheduleForLater ? "Schedule Post" : "Post Now")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canSubmit ? Color.teal : Color.gray)
                )
            }
            .disabled(!canSubmit)
            .animation(.easeInOut(duration: 0.2), value: canSubmit)
        }
    }

    // ── SUBMIT LOGIC ──
    // Validates, creates a ScheduledPost, saves to SwiftData, navigates to confirmation
    private func submitPost() {

        // Validation checks
        if caption.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Please write a caption for your post."
            showValidationAlert = true
            return
        }

        if !facebookSelected && !instagramSelected {
            validationMessage = "Please select at least one platform."
            showValidationAlert = true
            return
        }

        if !gdprConfirmed {
            validationMessage = "You must confirm the GDPR statement before posting."
            showValidationAlert = true
            return
        }

        if scheduleForLater && scheduledDate <= Date() {
            validationMessage = "Scheduled time must be in the future."
            showValidationAlert = true
            return
        }

        // Create the ScheduledPost model
        let post = ScheduledPost(
            caption: caption,
            platforms: selectedPlatforms,
            scheduledFor: scheduleForLater ? scheduledDate : Date(),
            imageNames: selectedItems.map { $0.imageName },
            gdprConfirmedAt: Date()
        )

        // Save to SwiftData (local database — persistent across app launches)
        modelContext.insert(post)

        // Mark selected items as posted
        for item in selectedItems {
            item.isPosted = true
        }

        // Navigate to confirmation screen
        savedPost = post
        navigateToConfirmation = true
    }
}

// ── PLATFORM CHIP ──
// Tappable toggle button for Facebook / Instagram
struct PlatformChip: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(name)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .white : .primary)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color : Color(.systemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? color : Color(.separator), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// ── SCHEDULE TOGGLE BUTTON ──
// "Post Now" / "Schedule" segmented-style control
struct ScheduleToggleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .white : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.teal : Color.clear)
                    .padding(3)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// Preview
#Preview {
    NavigationStack {
        CreatePostView(selectedItems: [
            MediaItem(imageName: "photo_arts", category: "Arts & Crafts",
                      consentStatus: .approved, childCount: 3),
            MediaItem(imageName: "photo_outdoor", category: "Outdoor Play",
                      consentStatus: .approved, childCount: 5)
        ])
    }
    .modelContainer(for: [MediaItem.self, ScheduledPost.self], inMemory: true)
}
