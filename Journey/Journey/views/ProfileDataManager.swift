import Foundation
import UIKit

struct ProfileInfo: Codable {
    var name: String
    var email: String
    var bio: String
    var imageFilename: String? // stored in documents directory
}

final class ProfileDataManager {
    static let shared = ProfileDataManager()

    private init() {}

    private let defaults = UserDefaults.standard
    private let profileKey = "profile.info"

    // MARK: - Public API

    func loadProfile() -> (info: ProfileInfo, image: UIImage?) {
        let info = loadProfileInfo()
        let image = loadImage(filename: info.imageFilename)
        return (info, image)
    }

    func saveProfile(name: String, email: String, bio: String, image: UIImage?) {
        var imageFilename: String? = nil
        if let image {
            imageFilename = saveImage(image)
        } else {
            // If image is nil, remove existing stored image filename
            var existing = loadProfileInfo()
            if let existingFilename = existing.imageFilename {
                removeImage(filename: existingFilename)
                existing.imageFilename = nil
                let info = ProfileInfo(name: name, email: email, bio: bio, imageFilename: nil)
                saveProfileInfo(info)
                return
            }
        }
        let info = ProfileInfo(name: name, email: email, bio: bio, imageFilename: imageFilename)
        saveProfileInfo(info)
    }

    // MARK: - Info persistence

    private func loadProfileInfo() -> ProfileInfo {
        if let data = defaults.data(forKey: profileKey),
           let info = try? JSONDecoder().decode(ProfileInfo.self, from: data) {
            return info
        }
        return ProfileInfo(name: "", email: "", bio: "", imageFilename: nil)
    }

    private func saveProfileInfo(_ info: ProfileInfo) {
        if let data = try? JSONEncoder().encode(info) {
            defaults.set(data, forKey: profileKey)
        }
    }

    // MARK: - Image persistence

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveImage(_ image: UIImage) -> String? {
        let filename = "profile_\(UUID().uuidString).jpg"
        let url = documentsDirectory().appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            // Remove old images to avoid bloat
            removeAllProfileImages()
            try data.write(to: url)
            return filename
        } catch {
            print("Failed to save profile image: \(error)")
            return nil
        }
    }

    private func loadImage(filename: String?) -> UIImage? {
        guard let filename else { return nil }
        let url = documentsDirectory().appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func removeImage(filename: String) {
        let url = documentsDirectory().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    private func removeAllProfileImages() {
        let dir = documentsDirectory()
        let contents = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        for url in contents where url.lastPathComponent.hasPrefix("profile_") {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
