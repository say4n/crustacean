//
//  CommentView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import MarkdownUI
import SwiftUI

struct CommentView: View {
    let commentHierarchy: Comment

    private let hierarchyColors: [Color] = [
        .cyan,
        .yellow,
        .teal,
        .indigo,
        .mint,
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            if commentHierarchy.depth != -1 {
                byline
            }

            Markdown(commentHierarchy.commentPlain)
                .markdownBlockStyle(\.blockquote) { configuration in
                    configuration.label
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .markdownTextStyle {
                            BackgroundColor(nil)
                        }
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 4)
                        }
                        .background(Color.secondary.opacity(0.2))
                }.markdownTextStyle(\.text) {
                    FontSize(.em(1))
                }

            ForEach(commentHierarchy.children, id: \.shortId) { child in
                CommentView(commentHierarchy: child)
            }
            .padding(.leading, 8)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(hierarchyColors[(commentHierarchy.depth + 1) % hierarchyColors.count])
                    .frame(width: 4)
            }

            Divider()
        }
    }

    var byline: some View {
        HStack {
            let dateString = Date.parseISO(from: commentHierarchy.createdAt)?.timeAgoDisplay() ?? ""

            HStack {
                Link(commentHierarchy.commentingUser, destination: URL(string: "https://lobste.rs/~\(commentHierarchy.commentingUser)")!)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(Color.primary)
                Link(dateString, destination: URL(string: commentHierarchy.shortIdUrl)!)
            }

            Spacer()

            HStack {
                Image(systemName: "arrow.up")
                Text(commentHierarchy.score.description)
            }
        }
        .padding(.trailing, 8)
        .padding(.bottom, 8)
    }
}

// #Preview {
//    CommentView()
// }
