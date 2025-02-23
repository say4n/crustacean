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

/// See: https://github.com/lobsters/lobsters/blob/55bfc00be02f6df5f008b69f6cec26a3219a1dd0/app/models/vote.rb#L26-L32
enum CommentFlagReasons: String, CaseIterable, Identifiable {
    var id: Self {
        return self
    }

    case offTopic = "Off-topic"
    case meToo = "Me-too"
    case troll = "Troll"
    case unkind = "Unkind"
    case spam = "Spam"

    var intValue: Int {
        switch self {
        case .offTopic:
            return 0
        case .meToo:
            return 1
        case .troll:
            return 2
        case .unkind:
            return 3
        case .spam:
            return 4
        }
    }
}

/// See: https://github.com/lobsters/lobsters/blob/55bfc00be02f6df5f008b69f6cec26a3219a1dd0/app/models/vote.rb#L39-L44
enum StoryFlagReasons: String, CaseIterable {
    case offTopic = "Off-topic"
    case alreadyPosted = "Already Posted"
    case brokenLink = "Broken Link"
    case spam = "Spam"

    var intValue: Int {
        switch self {
        case .offTopic:
            return 0
        case .alreadyPosted:
            return 1
        case .brokenLink:
            return 2
        case .spam:
            return 3
        }
    }
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
