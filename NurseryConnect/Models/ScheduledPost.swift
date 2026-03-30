//
//  ScheduledPost.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import Foundation
import SwiftData

// This model stores every post the coordinator creates.
// It is the GDPR audit record — once saved, it is never deleted.
@Model
class ScheduledPost {

    var id: UUID

    // Caption typed by the coordinator
    var caption: String

    // Which platforms were selected (stored as comma-separated string)
    // e.g. "facebook,instagram" or "facebook"
    var platformsRaw: String

    // When the post was created (always recorded for GDPR audit trail)
    var createdAt: Date

    // When the post is scheduled to go live
    var scheduledFor: Date

    // Status of the post
    var status: PostStatus

    // GDPR confirmation — coordinator must tick this before posting
    // Storing the timestamp when they confirmed
    var gdprConfirmedAt: Date?

    // Names of MediaItem imageNames used (comma-separated)
    // We store names not UUIDs so the audit log is human-readable
    var imageNamesRaw: String

    // Computed: array of platform strings
    var platforms: [String] {
        platformsRaw.split(separator: ",").map { String($0) }
    }

    // Computed: array of image names
    var imageNames: [String] {
        imageNamesRaw.split(separator: ",").map { String($0) }
    }

    init(
        caption: String,
        platforms: [String],
        scheduledFor: Date,
        imageNames: [String],
        gdprConfirmedAt: Date? = nil
    ) {
        self.id = UUID()
        self.caption = caption
        self.platformsRaw = platforms.joined(separator: ",")
        self.scheduledFor = scheduledFor
        self.imageNamesRaw = imageNames.joined(separator: ",")
        self.createdAt = Date()
        self.status = .scheduled
        self.gdprConfirmedAt = gdprConfirmedAt
    }
}

// Post lifecycle status
enum PostStatus: String, Codable, CaseIterable {
    case scheduled = "Scheduled"
    case posted    = "Posted"
    case failed    = "Failed"

    var icon: String {
        switch self {
        case .scheduled: return "clock.fill"
        case .posted:    return "checkmark.circle.fill"
        case .failed:    return "exclamationmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .scheduled: return "orange"
        case .posted:    return "green"
        case .failed:    return "red"
        }
    }
}
