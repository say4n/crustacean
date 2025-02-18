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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(postData.title)
                    .font(.headline)

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

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    var bylineString: LocalizedStringKey {
        let byOrVia = if postData.userIsAuthor { "by" } else { "via" }
        let dateString = Date.parseISO(from: postData.createdAt)?.timeAgoDisplay() ?? ""
        return "\(byOrVia) \(postData.submitterUser) \(dateString)"
    }

    var byline: some View {
        HStack {
            Text(bylineString)

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
