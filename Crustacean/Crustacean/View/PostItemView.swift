//
//  PostItemView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Flow
import SwiftUI

struct PostItemView: View {
    let data: Post

    private var avatarURL: URL? {
        URL(string: "https://lobste.rs/avatars/\(data.submitterUser)-32.png")
    }

    var body: some View {
        NavigationLink {
            PostDetailView(postData: data)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(data.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                HFlow(rowSpacing: 4) {
                    ForEach(data.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .colorInvert()
                            .background(Color.primary.gradient)
                            .clipShape(Capsule())
                    }

                    if data.url != "" && !data.url.contains("lobste.rs") {
                        Text(URL(string: data.url)?.host ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                byline
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    var byline: some View {
        HStack(spacing: 8) {
            AsyncImage(url: avatarURL) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                } else {
                    Color.secondary.opacity(0.2)
                }
            }
            .frame(width: 16, height: 16)
            .clipShape(Circle())

            let dateString = Date.parseISO(from: data.createdAt)?.timeAgoDisplay() ?? ""

            Link(data.submitterUser, destination: URL(string: "https://lobste.rs/~\(data.submitterUser)")!)
                .foregroundStyle(.secondary)

            Circle()
                .frame(width: 4, height: 4)
                .foregroundColor(Color.secondary.opacity(0.6))

            Link(dateString, destination: URL(string: data.shortIdUrl)!)
                .foregroundStyle(.secondary)
                .layoutPriority(1)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: data.isUpvoted == true ? "arrow.up.circle.fill" : "arrow.up")
                Text(data.score.description)
            }
            .fontWeight(data.isUpvoted == true ? .bold : .regular)
            .foregroundStyle(data.isUpvoted == true ? Color.accentColor : Color.secondary)

            HStack(spacing: 4) {
                Image(systemName: "bubble.right")
                Text(data.commentCount.description)
            }
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}

// #Preview {
//    PostView()
// }