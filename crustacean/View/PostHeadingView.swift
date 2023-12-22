//
//  PostHeadingView.swift
//  crustacean
//
//  Created by Sayan Goswami on 23/12/2023.
//

import SwiftUI

struct PostHeadingView: View {
    let post: Post
    
    @State private var createdAt: String = ""
    @State private var userName: String = ""
    @State private var userProfile: String = ""
    @State private var postUrl: String = ""
    @State private var byLine = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(post.title)
                .font(.headline)
            
            if let hostname = URL(string: post.url)?.host {
                Text("[\(hostname)](\(post.url))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            HStack (alignment: .firstTextBaseline) {
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
            }.font(.footnote)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(.init(byLine))
                
                Spacer()
                
                Label("\(post.score)", systemImage: "arrow.up.circle")
                    .labelStyle(.titleAndIcon)
                
                Label("\(post.comment_count)", systemImage: "text.bubble")
                    .labelStyle(.titleAndIcon)
                
                Label(createdAt, systemImage: "clock")
                    .labelStyle(.titleAndIcon)
            }.font(.footnote)
                .foregroundStyle(.secondary)
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
    PostHeadingView(
        post: Post(short_id: "test1d", short_id_url: "https://lobste.rs/s/test1d", created_at: DateFormatter().date(from: "2023-12-12T09:19:38.000-06:00") ?? Date.now, title: "test title", url: "https://example.com", score: 14, flags: 0, comment_count: 5, description: "description goes here", description_plain: "description_plain goes here", comments_url: "https://lobste.rs/s/test1d/test_title", submitter_user: User(username: "userName", created_at: DateFormatter().date(from: "2020-01-20T08:00:08.000-06:00") ?? Date.now, is_admin: false, about: "bio", is_moderator: false, karma: 100, avatar_url: "/avatars/avatar.png", invited_by_user: "someOtherUser"), user_is_author: false, tags: ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"])
        
    )
}
