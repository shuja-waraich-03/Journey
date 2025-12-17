//
//  ImageManager.swift
//  Journey
//
//  Created by Camposm on 11/17/25.
//

import UIKit

/**
 * ImageManager - Manages local storage of journal images
 *
 * This class handles:
 * - Saving images to local storage
 * - Loading images from local storage
 * - Deleting images from local storage
 * - Using the Documents directory for persistent storage
 */
class ImageManager {
  static let shared = ImageManager()

  private let fileManager = FileManager.default
  private let imageDirectory = "JournalImages"

  /* get the directory URL for storing images */
  private var imagesDirectoryURL: URL? {
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    let imageDir = documentsDirectory.appendingPathComponent(imageDirectory)

    /* create directory if it doesn't exist */
    if !fileManager.fileExists(atPath: imageDir.path) {
      try? fileManager.createDirectory(at: imageDir, withIntermediateDirectories: true)
    }

    return imageDir
  }

  /**
   * Save an image to local storage
   *
   * - Parameter data: The image data to save
   * - Returns: The filename of the saved image, or nil if failed
   */
  func saveImage(_ data: Data) -> String? {
    guard let imageDir = imagesDirectoryURL else {
      print("Error: Could not get images directory URL")
      return nil
    }

    /* generate unique filename */
    let filename = "\(UUID().uuidString).jpg"
    let fileURL = imageDir.appendingPathComponent(filename)

    do {
      try data.write(to: fileURL)
      print("Successfully saved image: \(filename)")
      return filename
    } catch {
      print("Error saving image: \(error)")
      return nil
    }
  }

  /**
   * Load an image from local storage
   *
   * - Parameter filename: The filename of the image to load
   * - Returns: UIImage if found, nil otherwise
   */
  func loadImage(filename: String) -> UIImage? {
    guard let imageDir = imagesDirectoryURL else {
      print("Error: Could not get images directory URL")
      return nil
    }

    let fileURL = imageDir.appendingPathComponent(filename)

    guard fileManager.fileExists(atPath: fileURL.path) else {
      print("Image file not found: \(filename)")
      return nil
    }

    guard let data = try? Data(contentsOf: fileURL) else {
      print("Error reading image data: \(filename)")
      return nil
    }

    return UIImage(data: data)
  }

  /**
   * Delete an image from local storage
   *
   * - Parameter filename: The filename of the image to delete
   */
  func deleteImage(filename: String) {
    guard let imageDir = imagesDirectoryURL else {
      print("Error: Could not get images directory URL")
      return
    }

    let fileURL = imageDir.appendingPathComponent(filename)

    do {
      try fileManager.removeItem(at: fileURL)
      print("Successfully deleted image: \(filename)")
    } catch {
      print("Error deleting image: \(error)")
    }
  }

  /**
   * Delete multiple images
   *
   * - Parameter filenames: Array of filenames to delete
   */
  func deleteImages(filenames: [String]) {
    for filename in filenames {
      deleteImage(filename: filename)
    }
  }
}
