//
//  CSRFUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/08/2025.
//

import Foundation
import OSLog

private let csrfLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CSRFUtils")

/// Lobste.rs runs Rails with `protect_from_forgery` (Rails 8 uses the
/// `:null_session` strategy). A write request without a valid
/// `authenticity_token` (or `X-CSRF-Token`) gets its session nulled server
/// side, so every logged-in POST would otherwise come back as
/// `"not logged in"`. The token is bound to the session and echoed in the
/// `<meta name="csrf-token">` tag of any page fetched with the same cookies.
private final class CSRFStore: @unchecked Sendable {
    static let shared = CSRFStore()

    private let lock = NSLock()
    private var token: String?
    private var fetchedAt: Date?

    func get() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return token
    }

    func set(_ token: String) {
        lock.lock()
        defer { lock.unlock() }
        self.token = token
        fetchedAt = Date()
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }
        token = nil
        fetchedAt = nil
    }

    func isValid() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let fetchedAt else { return false }
        return Date().timeIntervalSince(fetchedAt) < 300
    }
}

/// Fetches (and caches for a short time) the CSRF token for the app's current
/// Lobste.rs session. The fetch must bypass the local cache so it always gets
/// a live page rendered for the cookies we hold.
func csrfToken(forceRefresh: Bool = false) async -> String? {
    let store = CSRFStore.shared

    if !forceRefresh, let token = store.get(), store.isValid() {
        return token
    }

    var request = URLRequest(url: BASE_URL)
    request = await request.bless()
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

    do {
        let (data, _) = try await URLSession.shared.data(for: request)

        guard let html = String(data: data, encoding: .utf8),
              let token = extractCSRFToken(from: html) else {
            return nil
        }

        store.set(token)
        return token
    } catch {
        csrfLogger.error("Could not fetch CSRF token: \(error.localizedDescription)")
        return nil
    }
}

func resetCSRFTokenCache() {
    CSRFStore.shared.reset()
}

private func extractCSRFToken(from html: String) -> String? {
    let pattern = #"name="csrf-token"\s+content="([^"]+)""#

    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..<html.endIndex, in: html)),
          let range = Range(match.range(at: 1), in: html) else {
        return nil
    }

    return String(html[range])
}

/// Builds an `application/x-www-form-urlencoded` body from a dictionary.
func formUrlEncodedBody(_ params: [String: String]) -> Data? {
    var components = URLComponents()
    components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    return components.query?.data(using: .utf8)
}