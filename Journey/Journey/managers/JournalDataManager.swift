//
//  JournalDataManager.swift
//  Journey
//
//  Created by Camposm on 11/17/25.
//

import Foundation

/**
 * JournalDataManager - Manages local storage of journal entries
 *
 * This class handles:
 * - Saving journals to local storage
 * - Loading journals from local storage
 * - Deleting journals from local storage
 * - Using JSON encoding/decoding with FileManager
 */
class JournalDataManager {
  static let shared = JournalDataManager()

  private let fileManager = FileManager.default
  private let fileName = "journals.json"

  /* get the file URL for storing journals */
  private var fileURL: URL? {
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    return documentsDirectory.appendingPathComponent(fileName)
  }

  /**
   * Load all journals from local storage
   * Returns an array of Journal objects, or empty array if none exist
   */
  func loadJournals() -> [Journal] {
    guard let fileURL = fileURL else {
      print("Error: Could not get file URL")
      return []
    }

    /* check if file exists */
    guard fileManager.fileExists(atPath: fileURL.path) else {
      print("No saved journals found, returning empty array")
      return []
    }

    do {
      let data = try Data(contentsOf: fileURL)
      let journals = try JSONDecoder().decode([Journal].self, from: data)
      print("Successfully loaded \(journals.count) journals")
      return journals
    } catch {
      print("Error loading journals: \(error)")
      return []
    }
  }

  /**
   * Save journals to local storage
   * - Parameter journals: Array of journals to save
   */
  func saveJournals(_ journals: [Journal]) {
    guard let fileURL = fileURL else {
      print("Error: Could not get file URL")
      return
    }

    do {
      let data = try JSONEncoder().encode(journals)
      try data.write(to: fileURL)
      print("Successfully saved \(journals.count) journals")
    } catch {
      print("Error saving journals: \(error)")
    }
  }

  /**
   * Add a new journal or update existing one
   * - Parameter journal: The journal to add or update
   */
  func addOrUpdateJournal(_ journal: Journal) {
    var journals = loadJournals()

    /* check if journal already exists (update) */
    if let index = journals.firstIndex(where: { $0.id == journal.id }) {
      var updatedJournal = journal
      updatedJournal.updatedAt = Date()
      journals[index] = updatedJournal
      print("Updated existing journal: \(journal.title ?? "Untitled")")
    } else {
      /* add new journal */
      journals.append(journal)
      print("Added new journal: \(journal.title ?? "Untitled")")
    }

    saveJournals(journals)
  }

  /**
   * Delete a journal by ID
   * - Parameter id: The ID of the journal to delete
   */
  func deleteJournal(withId id: String) {
    var journals = loadJournals()

    /* find the journal and delete its associated images */
    if let journal = journals.first(where: { $0.id == id }) {
      if let imageFilenames = journal.images {
        ImageManager.shared.deleteImages(filenames: imageFilenames)
      }
    }

    journals.removeAll { $0.id == id }
    saveJournals(journals)
    print("Deleted journal with ID: \(id)")
  }
}
