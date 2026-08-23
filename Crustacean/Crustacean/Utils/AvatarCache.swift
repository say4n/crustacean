//
//  AvatarCache.swift
//  Crustacean
//
//  Created by Sayan Goswami on 24/08/2025.
//

import Foundation
import UIKit

/// Caches submitter avatars in memory and on disk so the 32pt avatars in
/// feed rows are fetched once per user and never re-downloaded between
/// launches. Users without an avatar are also remembered so they aren't
/// probed every time their stories appear.
actor AvatarCache {
    static let shared = AvatarCache()

    private var memory: [String: UIImage] = [:]
    private var missingUsers = Set<String>()

    private var cacheDirectory: URL? {
        guard let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = base.appendingPathComponent("Avatars", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func imageURL(for username: String) -> URL? {
        cacheDirectory?.appendingPathComponent("\(username).png")
    }

    private func missingMarkerURL(for username: String) -> URL? {
        cacheDirectory?.appendingPathComponent("\(username).missing")
    }

    /// Clears the in-memory and on-disk avatar cache, including the
    /// "no avatar" markers, so all avatars are re-fetched on next use.
    func clearCache() {
        memory.removeAll()
        missingUsers.removeAll()

        guard let directory = cacheDirectory else { return }
        try? FileManager.default.removeItem(at: directory)
    }

    func load(username: String) async -> UIImage? {
        if let memoryImage = memory[username] {
            return memoryImage
        }

        if missingUsers.contains(username) {
            return nil
        }

        let diskURL = imageURL(for: username)
        let markerURL = missingMarkerURL(for: username)

        if let markerURL, FileManager.default.fileExists(atPath: markerURL.path) {
            missingUsers.insert(username)
            return nil
        }

        if let diskURL, let data = try? Data(contentsOf: diskURL), let image = UIImage(data: data) {
            memory[username] = image
            return image
        }

        guard let url = URL(string: "https://lobste.rs/avatars/\(username)-32.png"),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            // Remember the miss so we don't keep probing users without avatars.
            missingUsers.insert(username)
            if let markerURL {
                try? Data().write(to: markerURL)
            }
            return nil
        }

        if let diskURL {
            try? data.write(to: diskURL)
        }
        memory[username] = image
        return image
    }
}