//
//  CommentView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import OSLog
import SwiftData
import SwiftUI

struct CommentView: View {
    let commentHierarchy: Comment
    var onReply: ((String, String) -> Void)? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL

    @Query private var filteredUsers: [FilteredPerson]
    @Query private var filteredComments: [FilteredCommentItem]

    private let hierarchyColors: [Color] = [
        .cyan,
        .yellow,
        .teal,
        .indigo,
        .mint,
    ]

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CommentView")

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("demoMode") private var demoMode = false

    @State private var localScore = 0
    @State private var isUpvoted: Bool? = nil
    @State private var expandComments = true

    @State private var showFlagAlert = false
    @State private var showHideAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            if commentHierarchy.depth != -1 {
                byline
            }

            Group {
                if commentHierarchy.isHidden {
                    Text("Comment hidden by you.")
                        .foregroundStyle(.secondary)
                } else {
                    MarkdownView(text: commentHierarchy.commentPlain, score: commentHierarchy.score)
                }

                VStack(spacing: 0) {
                    ForEach(commentHierarchy.children, id: \.shortId) { child in
                        CommentView(commentHierarchy: child, onReply: onReply)
                    }
                }
            }
            .frame(
                height: expandComments ? nil : 0,
                alignment: .top
            ).clipped()

            if commentHierarchy.depth >= 0 {
                Divider()
            }
        }
        .padding(.leading, commentHierarchy.depth >= 0 ? 8 : 0)
        .overlay(alignment: .leading) {
            if commentHierarchy.depth >= 0 {
                Capsule()
                    .fill(hierarchyColors[commentHierarchy.depth % hierarchyColors.count])
                    .frame(width: 4)
            }
        }
        .padding(.bottom, 8)
        .onAppear {
            localScore = commentHierarchy.score
        }
    }

    var byline: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation {
                    expandComments.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    let dateString = Date.parseISO(from: commentHierarchy.createdAt)?.timeAgoDisplay() ?? ""

                    Link(commentHierarchy.commentingUser, destination: URL(string: "https://lobste.rs/~\(commentHierarchy.commentingUser)")!)

                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundColor(Color.primary.opacity(0.4))

                    Link(dateString, destination: URL(string: commentHierarchy.shortIdUrl)!)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 4) {
                Image(systemName: isUpvoted == true ? "arrow.up.circle.fill" : "arrow.up")
                Text(localScore.description)
            }
            .fontWeight(isUpvoted == true ? .bold : .regular)
            .foregroundStyle(isUpvoted == true ? Color.accentColor : Color.primary)

            if isLoggedIn || demoMode {
                Menu {
                    Button {
                        onReply?(commentHierarchy.shortId, commentHierarchy.commentingUser)
                    } label: {
                        Label("Reply", systemImage: "arrowshape.turn.up.left")
                    }

                    if isUpvoted == true {
                        Button {
                            Task {
                                await vote(.unvote)
                            }
                        } label: {
                            Label("Unvote", image: "Unvote")
                        }
                    } else {
                        Button {
                            Task {
                                await vote(.upvote)
                            }
                        } label: {
                            Label("Upvote", systemImage: "arrowshape.up.fill")
                        }
                    }

                    Button {
                        logger.info("Flag")
                        showFlagAlert = true
                    } label: {
                        Label("Flag", systemImage: "ellipsis")
                    }

                    Button {
                        logger.info("Hide")
                        showHideAlert = true
                    } label: {
                        Label("Hide", systemImage: "eye.slash")
                    }

                    Divider()

                    Button {
                        openURL(URL(string: commentHierarchy.shortIdUrl)!)
                    } label: {
                        Label("Open on Lobste.rs", systemImage: "safari")
                    }

                    ShareLink(item: URL(string: commentHierarchy.shortIdUrl)!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .alert("Flag", isPresented: $showFlagAlert) {
                    ForEach(CommentFlagReasons.allCases) { reason in
                        Button(reason.rawValue) {
                            Task {
                                await flagItem(shortId: commentHierarchy.shortId, entity: .comments, reason: reason)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .alert("Hide", isPresented: $showHideAlert) {
                    Button("Comment") {
                        logger.info("Hiding comment: \(commentHierarchy.shortId)")
                        context.insert(FilteredCommentItem(shortId: commentHierarchy.shortId))
                        withAnimation {
                            commentHierarchy.isHidden = true
                        }
                    }
                    Button("User") {
                        logger.info("Hiding user: \(commentHierarchy.commentingUser)")
                        context.insert(FilteredPerson(username: commentHierarchy.commentingUser))
                        withAnimation {
                            commentHierarchy.isHidden = true
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }

            Spacer()

            Image(systemName: expandComments ? "arrow.down.and.line.horizontal.and.arrow.up" : "arrow.up.and.line.horizontal.and.arrow.down")
                .contentTransition(.symbolEffect(.replace))
        }
        .padding(4)
        .background(Color.secondary.opacity(0.1))
        .overlay(alignment: .bottom) {
            Capsule()
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onAppear {
            commentHierarchy.isHidden = filteredUsers.map { $0.username }.contains(commentHierarchy.commentingUser) || filteredComments.map { $0.shortId }.contains(commentHierarchy.shortId)
        }
    }

    private func vote(_ action: ActionType) async {
        guard let voteResponse = await castVote(shortId: commentHierarchy.shortId, entity: .comments, action: action), voteResponse == .success else { return }

        withAnimation {
            isUpvoted = (action == .upvote)
        }

        // Reconcile with the authoritative score; the vote may have been a
        // no-op if this comment was already upvoted (e.g. in another client).
        if let freshScore = await fetchCommentScore(shortId: commentHierarchy.shortId) {
            localScore = freshScore
        } else if action == .upvote {
            localScore += 1
        } else {
            localScore -= 1
        }
    }
}

// #Preview {
//    CommentView()
// }