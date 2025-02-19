//
//  CommentDataSource.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Foundation
import OSLog
import SwiftUI
import SwiftyJSON

@MainActor class CommentDataSource: ObservableObject {
    static let shared = CommentDataSource()

    @Published var comments = [String: Comment]()
    @Published var state = DataSourceState.unknown

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CommentDataSource")

    func fetchComments(shortId: String) async throws {
        DispatchQueue.main.async {
            self.state = .loading
        }

        let endpoint = BASE_URL.appending(path: "/s/\(shortId).json")

        logger.info("Fetching comments for \(shortId)")

        var data: Data?
        do {
            data = try await fetchDataFromURL(endpoint)
        } catch {
            logger.error("Could not fetch comments for \(shortId): \(error.localizedDescription)")

            DispatchQueue.main.async {
                self.state = .error
            }

            return
        }

        logger.info("Parsing response to JSON for \(shortId)")
        let jsonData = JSON(data!)

        logger.info("Decoding list of comments from JSON for \(shortId)")

        var fetchedComments: [Comment]?
        do {
            // This is a in-order traversal of comment hierarchy.
            fetchedComments = try JSONDecoder().decode([Comment].self, from: jsonData["comments"].rawData())
        } catch {
            logger.error("Could not decode list from JSON: \(error.localizedDescription), \(jsonData["comments"])")

            DispatchQueue.main.async {
                self.state = .error
            }

            return
        }

        logger.info("Constructing hierarchy from fetched comments for \(shortId)")
        var treeMap = [String: Comment]()

        // Add nodes.
        for comment in fetchedComments! {
            treeMap[comment.shortId] = comment
        }

        // Fake root node.
        treeMap[shortId] = Comment.getNullComment()

        // Add edges.
        for comment in fetchedComments! {
            let child = treeMap[comment.shortId]!

            if comment.parentComment != nil {
                logger.info("\(comment.parentComment!) -> \(child.shortId)")

                let newValue = treeMap[comment.parentComment!]
                newValue?.children.append(child)
                treeMap.updateValue(newValue!, forKey: comment.parentComment!)

                logger.info("Updated parent has \(treeMap[comment.parentComment!]?.children.count ?? 0) children")
            } else {
                logger.info("@ -> \(child.shortId)")

                treeMap[shortId]?.children.append(child)
            }
        }

        DispatchQueue.main.async {
            self.logger.info("Updating comment data source for \(shortId)")
            self.comments[shortId] = treeMap[shortId]

            withAnimation {
                self.state = .loaded
            }

            self.objectWillChange.send()
        }
    }
}
