//
//  PostDetailView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Flow
import SwiftData
import SwiftUI

struct PostDetailView: View {
    let postData: Post

    @ObservedObject var commentsData = CommentDataSource.shared

    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("demoMode") private var demoMode = false

    @State private var score: Int
    @State private var isUpvoted: Bool? = nil

    @State private var showComposer = false
    @State private var composerParentShortId: String?
    @State private var replyingUsername: String?

    init(postData: Post) {
        self.postData = postData
        _score = State(initialValue: postData.score)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    if postData.url != "" {
                        Link(destination: URL(string: postData.url)!) {
                            Text(postData.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    } else {
                        Text(postData.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }.font(.system(size: 20, weight: .bold))

                HFlow(rowSpacing: 4) {
                    ForEach(postData.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .colorInvert()
                            .background(Color.primary.gradient)
                            .clipShape(Capsule())
                    }

                    if postData.url != "" {
                        Text(URL(string: postData.url)?.host ?? "")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }.padding(.bottom, 4)
                    .padding(.top, 0.1)

                byline

                if postData.descriptionPlain != "" {
                    Divider()
                        .padding(.bottom, 8)

                    MarkdownView(text: postData.descriptionPlain, score: postData.score)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom)
            .onAppear {
                markAsVisited()

                Task {
                    // Don't fetch comments if we have already fetched.
                    if commentsData.comments.keys.contains(postData.shortId) {
                        return
                    }

                    try? await commentsData.fetchComments(shortId: postData.shortId)
                }
            }

            composerBar

            switch commentsData.state {
            case .loading:
                Divider()
                ProgressView()
            case .error:
                Divider()
                Text("Error loading comments.")
            case .loaded:
                let rootNode = commentsData.comments[postData.shortId]

                if rootNode != nil && !rootNode!.children.isEmpty {
                    CommentView(commentHierarchy: rootNode!, onReply: { shortId, username in
                        composerParentShortId = shortId
                        replyingUsername = username
                        showComposer = true
                    })
                    .transition(.scale)
                } else {
                    // No comments.
                    Divider()
                    Text("No comments yet.")
                }
            case .unknown:
                Divider()
                Text("No comments yet.")
            }
        }.refreshable {
            Task {
                try? await commentsData.fetchComments(shortId: postData.shortId)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if isLoggedIn || demoMode {
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

                        Divider()
                    }

                    Button {
                        openURL(URL(string: postData.shortIdUrl)!)
                    } label: {
                        Label("Open on Lobste.rs", systemImage: "safari")
                    }

                    ShareLink(item: URL(string: postData.shortIdUrl)!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showComposer) {
            CommentComposerView(
                storyId: postData.shortId,
                storyTitle: postData.title,
                parentCommentShortId: composerParentShortId,
                replyingToUsername: replyingUsername
            ) {
                Task {
                    try? await commentsData.fetchComments(shortId: postData.shortId)
                }
            }
        }
    }

    var byline: some View {
        HStack {
            HStack(spacing: 4) {
                let byOrVia = if postData.userIsAuthor { "by" } else { "via" }
                let dateString = Date.parseISO(from: postData.createdAt)?.timeAgoDisplay() ?? ""

                Text(byOrVia)
                Link(postData.submitterUser, destination: URL(string: "https://lobste.rs/~\(postData.submitterUser)")!)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(Color.primary)
                Link(dateString, destination: URL(string: postData.shortIdUrl)!)
            }

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: isUpvoted == true ? "arrow.up.circle.fill" : "arrow.up")
                Text(score.description)
            }
            .fontWeight(isUpvoted == true ? .bold : .regular)
            .foregroundStyle(isUpvoted == true ? Color.accentColor : Color.primary)

            HStack {
                Image(systemName: "bubble")
                Text(postData.commentCount.description)
            }
        }
    }

    var composerBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()

            if isLoggedIn || demoMode {
                Button {
                    composerParentShortId = nil
                    replyingUsername = nil
                    showComposer = true
                } label: {
                    Label("Add a comment", systemImage: "square.and.pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 8)
            } else {
                Text("Log in from Settings to comment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
        }
    }

    private func vote(_ action: ActionType) async {
        guard let voteResponse = await castVote(shortId: postData.shortId, entity: .stories, action: action), voteResponse == .success else { return }

        withAnimation {
            isUpvoted = (action == .upvote)
        }

        // Reconcile with the authoritative score; the vote may have been a
        // no-op if this story was already upvoted (e.g. in another client).
        if let freshScore = await fetchStoryScore(shortId: postData.shortId) {
            score = freshScore
        } else if action == .upvote {
            score += 1
        } else {
            score -= 1
        }
    }

    private func markAsVisited() {
        let shortId = postData.shortId

        var descriptor = FetchDescriptor<VisitedPost>(predicate: #Predicate { $0.shortId == shortId })
        descriptor.fetchLimit = 1

        guard (try? context.fetchCount(descriptor)) ?? 0 == 0 else { return }

        context.insert(VisitedPost(shortId: shortId))
        try? context.save()
    }
}

#Preview {
    let data = """
    {
      "short_id": "mlly3p",
      "short_id_url": "https://lobste.rs/s/mlly3p",
      "created_at": "2025-02-17T04:46:45.000-06:00",
      "title": "What are you doing this week?",
      "url": "",
      "score": 4,
      "flags": 0,
      "comment_count": 3,
      "description": "<p>What are you doing this week? Feel free to share!</p>\n<p>Keep in mind it’s OK to do nothing at all, too.</p>\n",
      "description_plain": "What are you doing this week?\r\n\r\nKeep in mind it’s OK to do nothing at all, too.",
      "comments_url": "https://lobste.rs/s/mlly3p/what_are_you_doing_this_week",
      "submitter_user": "caius",
      "user_is_author": true,
      "tags": [
        "ask",
        "programming"
      ]
    }
    """.data(using: .utf8)

    PostDetailView(
        postData: try! JSONDecoder().decode(
            Post.self,
            from: data!
        )
    )
}