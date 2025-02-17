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
            Text(data.title)
                .font(.headline)

            Text(data.submitterUser)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// #Preview {
//    PostView()
// }
