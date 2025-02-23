//
//  InteractionHelpers.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/02/2025.
//

import SwiftUI

enum ActionType: String {
    case upvote
    case unvote
}

enum EntityType: String {
    case comments
    case stories
}

enum VoteResponse: Equatable {
    case success
    case error(String)
}

func castVote(shortId: String, entity: EntityType, action: ActionType) async -> VoteResponse? {
    let url = BASE_URL.appending(path: "/\(entity)/\(shortId)/\(action)")
    var voteResponse: VoteResponse?

    @AppStorage("isLoggedIn") var isLoggedIn = false

    do {
        let response = try await fetchDataFromURL(url, httpMethod: "POST")
        let responseString = String(data: response, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "UNKNOWN"

        // Logged out, update state to allow logging back in.
        if responseString == "not logged in" {
            isLoggedIn = false
        }

        voteResponse = responseString == "ok" ? .success : .error(responseString)
        logger.info("Response from \(action.rawValue): \(responseString)")
    } catch {
        logger.error("Could not \(action.rawValue) story: \(error)")
    }

    return voteResponse
}
