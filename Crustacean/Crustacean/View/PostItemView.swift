//
//  PostItemView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

struct PostItemView: View {
    let data: Post

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            Text(data.title)
                .font(.headline)

            byline
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var byOrVia: String { if data.userIsAuthor { "by " } else { "via " }}

    var byline: some View {
        HStack {
            Text(byOrVia + data.submitterUser)

            Spacer()

            if let date = Date.parseISO(from: data.createdAt) {
                Text(date.timeAgoDisplay())
            }
        }
    }
}

// #Preview {
//    PostView()
// }
