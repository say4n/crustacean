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

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                PostDetailView(postData: data)
            } label: {
                VStack(alignment: .leading) {
                    Text(data.title)
                        .font(.headline)

                    HFlow {
                        ForEach(data.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .colorInvert()
                                .background(Color.primary.gradient)
                                .clipShape(Capsule())
                        }
                    }.padding(.bottom, 4)
                        .padding(.top, 0.1)

                    byline
                }.contentShape(Rectangle())
            }.frame(alignment: .leading)
                .buttonStyle(.plain)

            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom)
    }

    var byline: some View {
        HStack {
            HStack(spacing: 4) {
                let byOrVia = if data.userIsAuthor { "by" } else { "via" }
                let dateString = Date.parseISO(from: data.createdAt)?.timeAgoDisplay() ?? ""

                Text(byOrVia)
                Link(data.submitterUser, destination: URL(string: "https://lobste.rs/~\(data.submitterUser)")!)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundColor(Color.primary)
                Link(dateString, destination: URL(string: data.shortIdUrl)!)
            }

            Spacer()

            HStack {
                Image(systemName: "arrow.up")
                Text(data.score.description)
            }

            HStack {
                Image(systemName: "bubble")
                Text(data.commentCount.description)
            }
        }
    }
}

// #Preview {
//    PostView()
// }
