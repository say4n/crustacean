//
//  SessionUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/08/2025.
//

import Foundation
import OSLog

enum SessionState {
    case loggedIn
    case loggedOut
    case unknown
}

/// Verifies the app's cookie session against Lobste.rs.
///
/// GET /login is a reliable probe: a logged-in user with a valid `lobster_trap`
/// session is redirected away from the login page, while a logged-out (or
/// expired/deactivated) session is served the login page itself.
func currentSessionState() async -> SessionState {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SessionUtils")

    var request = URLRequest(url: BASE_URL.appending(path: "login"))
    request = await request.bless()
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

    do {
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let path = response.url?.path else {
            return .unknown
        }

        return path == "/login" ? .loggedOut : .loggedIn
    } catch {
        logger.error("Could not check session state: \(error.localizedDescription)")
        return .unknown
    }
}