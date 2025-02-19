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

                HFlow {
                    ForEach(postData.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .bold()
                            .padding(.horizontal, 6)
                            .colorInvert()
                            .background(Color.primary.gradient)
                            .clipShape(Capsule())
                    }
                }.padding(.bottom, 4)
                    .padding(.top, 0.1)

                byline
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom)
            .onAppear {
                Task {
                    try await commentsData.fetchComments(shortId: postData.shortId)
                }
            }

            let rootNode = commentsData.comments[postData.shortId]

            if rootNode != nil && !rootNode!.children.isEmpty {
                CommentView(commentHierarchy: rootNode!)
            } else {
                // No comments.
                Text("No comments yet.")
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

// #Preview {
//    PostDetailView()
// }
