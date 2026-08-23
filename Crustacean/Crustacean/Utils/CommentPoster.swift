//
//  CommentPoster.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/08/2025.
//

import Foundation
import OSLog
import SwiftUI

enum CommentPostResponse: Equatable {
    case success
    case notLoggedIn
    case error(String)
}

/// Cancels URLSession's automatic redirect following so we can inspect the
/// 302 that Lobste.rs returns on a successful comment POST.
private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_: URLSession, task _: URLSessionTask, willPerformHTTPRedirection _: HTTPURLResponse, newRequest _: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

/// Posts a new comment (or reply) to Lobste.rs.
///
/// The site answers a successful POST with a 302 redirect to the posted
/// comment, a 400 "not logged in" when the session has expired, and a 200
/// HTML page when the comment is rejected (e.g. the posting speed limit).
func postComment(storyId: String, body: String, parentCommentShortId: String?) async -> CommentPostResponse {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CommentPoster")

    @AppStorage("isLoggedIn") var isLoggedIn = false

    let url = BASE_URL.appending(path: "comments")

    var urlComponents = URLComponents()
    urlComponents.queryItems = [
        URLQueryItem(name: "story_id", value: storyId),
        URLQueryItem(name: "comment", value: body),
    ]
    if let parentCommentShortId {
        urlComponents.queryItems?.append(URLQueryItem(name: "parent_comment_short_id", value: parentCommentShortId))
    }
    if let csrf = await csrfToken() {
        urlComponents.queryItems?.append(URLQueryItem(name: "authenticity_token", value: csrf))
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = urlComponents.query?.data(using: .utf8)

    do {
        let blessedRequest = await request.bless()
        let noRedirect = NoRedirectDelegate()
        let (data, response) = try await URLSession.shared.data(for: blessedRequest, delegate: noRedirect)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let responseString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "UNKNOWN"

        logger.info("Post comment response: \(statusCode) \(String(responseString.prefix(200)))")

        switch statusCode {
        case 302:
            return .success
        case 400:
            if responseString == "not logged in" {
                isLoggedIn = false
                return .notLoggedIn
            }
            return .error(responseString)
        case 200:
            return .error("Your comment could not be posted. Please wait a moment and try again.")
        default:
            return .error("Unexpected response from Lobste.rs (\(statusCode)).")
        }
    } catch {
        logger.error("Could not post comment: \(error.localizedDescription)")
        return .error("Network error, please try again.")
    }
}