//
//  Journal.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import Foundation

/**
 * Journal - Data Model for journal entries
 *
 * This struct represents a journal entry in the app.
 */
struct Journal: Codable {
  /* unique identifier */
  var id: String /* unique ID (e.g., "abc123xyz") */
  var createdAt: Date /* when this journal was created */
  var updatedAt: Date /* when this journal was last edited */

  /* custom properties - your journal data */
  var title: String? /* journal title (e.g., "My Trip to Paris") */
  var location: String? /* where journal was written (e.g., "San Francisco, CA") */
  var content: String? /* full journal text/story */
  var images: [String]? /* array of image URLs or file references */

  /* initializer to create new journals */
  init(id: String = UUID().uuidString, title: String? = nil, location: String? = nil, content: String? = nil, images: [String]? = nil) {
    self.id = id
    self.title = title
    self.location = location
    self.content = content
    self.images = images
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  /**
   * Computed Property: snippet
   *
   * Computed properties don't store data - they calculate a value on-the-fly.
   * This creates a short preview of the journal content for display in cards.
   *
   */
  var snippet: String {
    guard let content = content else { return "" }
    let maxLength = 100
    if content.count <= maxLength {
      return content
    }
    let trimmed = String(content.prefix(maxLength))
    return trimmed + "..."
  }

  /**
   * Computed Property: thumbnailImage
   *
   * Returns the first image from the images array to display as a thumbnail.
   *
   * Example:
   *   images = ["https://example.com/img1.jpg", "https://example.com/img2.jpg"]
   *   thumbnailImage = "https://example.com/img1.jpg"
   *
   *   images = nil or []
   *   thumbnailImage = nil
   */
  var thumbnailImage: String? {
    return images?.first
  }
}

extension Journal: Identifiable {}

let SAMPLE_JOURNALS: [Journal] = [
  {
    var journal = Journal(
      title: "Morning Reflections",
      location: "San Francisco, CA",
      content: "Woke up early today and spent some time thinking about my goals for this year. I want to focus on personal growth and building meaningful connections.",
      images: ["https://i.imgur.com/IdorGF4.png"]
    )
    journal.createdAt = Date().addingTimeInterval(-86400) /* 1 day ago */
    journal.updatedAt = journal.createdAt
    return journal
  }(),
  {
    var journal = Journal(
      title: "Beach Day Adventures",
      location: "Malibu, CA",
      content: "The ocean was so calm today. Spent hours just walking along the shore, collecting shells and watching the sunset. Sometimes the simple moments are the best.",
      images: ["https://i.imgur.com/f45Vtup.png"]
    )
    journal.createdAt = Date().addingTimeInterval(-172800) /* 2 days ago */
    journal.updatedAt = journal.createdAt
    return journal
  }(),
  {
    var journal = Journal(
      title: "Coffee Shop Musings",
      location: "Seattle, WA",
      content: "Found this amazing little coffee shop downtown. The atmosphere is perfect for journaling. Met an interesting person who shared their travel stories with me.",
      images: ["https://i.imgur.com/HYXlcFI.jpeg"]
    )
    journal.createdAt = Date().addingTimeInterval(-259200) /* 3 days ago */
    journal.updatedAt = journal.createdAt
    return journal
  }(),
  {
    var journal = Journal(
      title: "My Trip to Paris",
      location: "Paris, France",
      content: "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."
    )
    journal.createdAt = Date()
    journal.updatedAt = journal.createdAt
    return journal
  }(),
]
