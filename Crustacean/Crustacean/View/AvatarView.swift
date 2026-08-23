//
//  AvatarView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 24/08/2025.
//

import SwiftUI
import UIKit

struct AvatarView: View {
    let username: String
    var size: CGFloat = 16

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.secondary.opacity(0.2)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .task(id: username) {
            image = await AvatarCache.shared.load(username: username)
        }
    }
}