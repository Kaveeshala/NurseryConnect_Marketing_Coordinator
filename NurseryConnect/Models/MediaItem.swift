//
//  MediaItem.swift
//  NurseryConnect
//
//  Created by Geethmani on 2026-03-30.
//

import Foundation
import SwiftData

// @Model tells SwiftData to persist this in the local database
@Model
class MediaItem {
    
    // A unique ID for each photo — UUID() auto-generates one
    var id: UUID
    
    // The name of the image in Assets.xcassets (e.g., "photo_arts")
    var imageName: String
    
    // Activity category tag shown on the card
    var category: String
    
    // When this photo was added to the library
    var dateAdded: Date
    
    // Consent status — only "approved" photos should be postable
    var consentStatus: ConsentStatus
    
    // How many children appear in the photo (count only — no names, GDPR rule)
    var childCount: Int
    
    // Whether this photo has already been used in a post
    var isPosted: Bool
    
    // Initialiser — called when you create a new MediaItem
    init(
        imageName: String,
        category: String,
        dateAdded: Date = Date(),
        consentStatus: ConsentStatus = .pending,
        childCount: Int = 1,
        isPosted: Bool = false
    ) {
        self.id = UUID()
        self.imageName = imageName
        self.category = category
        self.dateAdded = dateAdded
        self.consentStatus = consentStatus
        self.childCount = childCount
        self.isPosted = isPosted
    }
}

// An enum for the consent status — using String so SwiftData can store it
enum ConsentStatus: String, Codable, CaseIterable {
    case approved = "Approved"
    case pending  = "Pending"
    
    // The colour to show the badge in
    var badgeColor: String {
        switch self {
        case .approved: return "green"
        case .pending:  return "orange"
        }
    }
    
    // The SF Symbol icon to show next to the badge label
    var icon: String {
        switch self {
        case .approved: return "checkmark.seal.fill"
        case .pending:  return "clock.fill"
        }
    }
}
