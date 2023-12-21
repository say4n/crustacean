//
//  PostListItemView.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import SwiftUI
import WrappingStack

struct PostListItemView: View {
    let post: Post
    @State private var createdAt: String = ""
    @State private var userName: String = ""
    @State private var userProfile: String = ""
    @State private var postUrl: String = ""
    
    @State private var byLine = ""
    
    var body: some View {
        NavigationLink {
            PostDetailView(post: post)
        } label: {
            VStack (alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                HStack {
                    Text(.init(byLine))
                    
                    WrappingHStack (id: \.self) {
                        ForEach(post.tags, id: \.self) { tag in
                            Section {
                                Text(tag)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(.white)
                                    .background(
                                        Capsule()
                                            .fill(.gray)
                                    )
                            }.padding(.horizontal, 2)
                        }
                    }
                }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack {
                    Label("\(post.score)", systemImage: "arrow.up.circle")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Label("\(post.comment_count)", systemImage: "text.bubble")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Label(createdAt, systemImage: "clock")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }.onAppear {
            createdAt = formatDateToHumanReadableDuration(date:post.created_at) ?? ""
            userName = post.submitter_user.username
            userProfile = "\(baseUrl)/u/\(userName)"
            postUrl = post.short_id_url
            byLine = "by [\(userName)](\(userProfile))"
        }
    }
}

#Preview {
    PostListItemView(
        post: Post(short_id: "test1d", short_id_url: "https://lobste.rs/s/test1d", created_at: DateFormatter().date(from: "2023-12-12T09:19:38.000-06:00") ?? Date.now, title: "test title", url: "https://example.com", score: 14, flags: 0, comment_count: 5, description: "", description_plain: "", comments_url: "https://lobste.rs/s/test1d/test_title", submitter_user: User(username: "userName", created_at: DateFormatter().date(from: "2020-01-20T08:00:08.000-06:00") ?? Date.now, is_admin: false, about: "bio", is_moderator: false, karma: 100, avatar_url: "/avatars/avatar.png", invited_by_user: "someOtherUser"), user_is_author: false, tags: ["tag"])
    )
}
