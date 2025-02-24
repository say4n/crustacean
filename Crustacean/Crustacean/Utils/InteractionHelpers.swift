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

protocol FlagReason {
    var rawValue: String { get }
    var flagValue: Character { get }
}

/// See: https://github.com/lobsters/lobsters/blob/55bfc00be02f6df5f008b69f6cec26a3219a1dd0/app/models/vote.rb#L26-L32
enum CommentFlagReasons: String, CaseIterable, Identifiable, FlagReason {
    var id: Self {
        return self
    }

    case offTopic = "Off-topic"
    case meToo = "Me-too"
    case troll = "Troll"
    case unkind = "Unkind"
    case spam = "Spam"

    var flagValue: Character {
        return Array(self.rawValue)[0]
    }
}

/// See: https://github.com/lobsters/lobsters/blob/55bfc00be02f6df5f008b69f6cec26a3219a1dd0/app/models/vote.rb#L39-L44
enum StoryFlagReasons: String, CaseIterable, Identifiable, FlagReason {
    var id: Self {
        return self
    }

    case offTopic = "Off-topic"
    case alreadyPosted = "Already Posted"
    case brokenLink = "Broken Link"
    case spam = "Spam"

    var flagValue: Character {
        return Array(self.rawValue)[0]
    }
}

func flagItem<T: FlagReason>(shortId: String, entity: EntityType, reason: T) async -> VoteResponse? {
    let url = BASE_URL.appending(path: "/\(entity)/\(shortId)/flag")
    var voteResponse: VoteResponse?

    @AppStorage("isLoggedIn") var isLoggedIn = false

    do {
        let formData = MultipartFormDataRequest(url: url)
        formData.addTextField(named: "reason", value: reason.flagValue.description)
            
        let request = await formData.asURLRequest().bless()
        let (response, _) = try await URLSession.shared.data(for: request)
        let responseString = String(data: response, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "UNKNOWN"

        // Logged out, update state to allow logging back in.
        if responseString == "not logged in" {
            isLoggedIn = false
        }

        voteResponse = responseString == "ok" ? .success : .error(responseString)
        logger.info("Response from flagging with \(reason.rawValue): \(responseString)")
    } catch {
        logger.error("Could not flag with \(reason.rawValue) story: \(error)")
    }

    return voteResponse
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
