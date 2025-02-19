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

    @State var expandComments: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            if commentHierarchy.depth != -1 {
                Button {
                    withAnimation {
                        expandComments.toggle()
                    }
                } label: {
                    byline
                        .contentShape(
                            Rectangle()
                        )
                        .background(
                            Color.secondary.opacity(0.1)
                        )
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                                .frame(height: 2)
                        }

                        .clipShape(
                            RoundedRectangle(cornerRadius: 4)
                        )
                }
                .buttonStyle(.plain)
            }

            Group {
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
                        ForegroundColor(commentHierarchy.score >= 0 ? Color.primary : Color.primary.opacity(0.4))
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
            }.frame(
                height: expandComments ? nil : 0,
                alignment: .top
            ).clipped()

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

                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(Color.primary)

                HStack {
                    Image(systemName: "arrow.up")
                    Text(commentHierarchy.score.description)
                }
            }

            Spacer()

            Image(systemName: expandComments ? "arrow.down.and.line.horizontal.and.arrow.up" : "arrow.up.and.line.horizontal.and.arrow.down")
                .contentTransition(.symbolEffect(.replace))
        }
        .padding(4)
    }
}

// #Preview {
//    CommentView()
// }
