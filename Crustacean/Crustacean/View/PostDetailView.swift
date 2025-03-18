//
//  PostDetailView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Flow
import SwiftUI

struct PostDetailView: View {
    let postData: Post

    @ObservedObject var commentsData = CommentDataSource.shared

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
                Task {
                    // Don't fetch comments if we have already fetched.
                    if commentsData.comments.keys.contains(postData.shortId) {
                        return
                    }

                    try await commentsData.fetchComments(shortId: postData.shortId)
                }
            }

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
                    CommentView(commentHierarchy: rootNode!)
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
                try await commentsData.fetchComments(shortId: postData.shortId)
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

            HStack {
                Image(systemName: "arrow.up")
                Text(postData.score.description)
            }

            HStack {
                Image(systemName: "bubble")
                Text(postData.commentCount.description)
            }
        }
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
      "description": "<p>What are you doing this week? Feel free to share!</p>\\n<p>Keep in mind it’s OK to do nothing at all, too.</p>\\n",
      "description_plain": "What are you doing this week? Feel free to share!\\r\\n\\r\\nKeep in mind it’s OK to do nothing at all, too.",
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
