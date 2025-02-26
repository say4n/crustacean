//
//  CommentDataSource.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Foundation
import OSLog
import SwiftData
import SwiftUI

@MainActor class CommentDataSource: ObservableObject {
    static let shared = CommentDataSource()

    @Published var comments = [String: Comment]()
    @Published var state = DataSourceState.unknown

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CommentDataSource")

    private let container = try? ModelContainer(for: FilteredPostItem.self, FilteredCommentItem.self, FilteredPerson.self)
    private var context: ModelContext? {
        container?.mainContext
    }

    private let hiddenUsersFetchDescriptor = FetchDescriptor<FilteredPerson>()
    private let hiddenCommentsFetchDescriptor = FetchDescriptor<FilteredCommentItem>()
    private var hiddenUsers: [String] {
        do {
            return try context?.fetch(hiddenUsersFetchDescriptor).map { $0.username } ?? []
        } catch {
            return []
        }
    }

    private var hiddenComments: [String] {
        do {
            return try context?.fetch(hiddenCommentsFetchDescriptor).map { $0.shortId } ?? []
        } catch {
            return []
        }
    }

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

        logger.info("Decoding list of comments from JSON for \(shortId)")

        var fetchedComments: [Comment]?
        do {
            // This is a in-order traversal of comment hierarchy.
            let wrappedComments = try JSONDecoder().decode(CommentWrapper.self, from: data!)
            fetchedComments = wrappedComments.comments
        } catch {
            logger.error("Could not decode list from JSON: \(error.localizedDescription), \(data?.debugDescription ?? "UNKNOWN")")

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

            if hiddenComments.contains(comment.shortId) || hiddenUsers.contains(comment.commentingUser) {
                child.isHidden = true
            }

            if comment.parentComment != nil {
                logger.info("\(comment.parentComment!) -> \(child.shortId)")

                let newValue = treeMap[comment.parentComment!]
                newValue?.children.append(child)

                if newValue != nil {
                    treeMap.updateValue(newValue!, forKey: comment.parentComment!)
                }

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
