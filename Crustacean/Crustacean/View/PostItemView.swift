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
            Divider()

            NavigationLink {
                PostDetailView()
            } label: {
                Text(data.title)
                    .font(.headline)
            }.frame(alignment: .leading)
                .buttonStyle(.plain)

            HFlow {
                ForEach(data.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 6)
                        .colorInvert()
                        .background(Color.primary.gradient)
                        .clipShape(Capsule())
                }
            }.padding(.bottom, 4)

            byline
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var bylineString: LocalizedStringKey {
        let byOrVia = if data.userIsAuthor { "by" } else { "via" }
        let dateString = Date.parseISO(from: data.createdAt)?.timeAgoDisplay() ?? ""
        return "\(byOrVia) \(data.submitterUser) \(dateString)"
    }

    var byline: some View {
        HStack {
            Text(bylineString)

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
