//
//  PostDetailView.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import SwiftUI
import WrappingStack

struct PostDetailView: View {
    let post: Post
    @State private var createdAt: String = ""
    @State private var byLine = ""
    @State private var comments: [Comment] = []
    @State private var commentState: DataFetchState = .Loading
    
    var body: some View {
        List {
            Section {
                VStack (alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    HStack {
                        Text(.init(byLine))
                        
                        WrappingHStack (id: \.self) {
                            ForEach(post.tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(.white)
                                    .background(
                                        Capsule()
                                            .fill(.gray)
                                    )
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    if !post.description.isEmpty {
                        Text(post.description)
                    }
                    
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
                }.background(
                    Color(UIColor.secondarySystemGroupedBackground)
                        .padding(.trailing, -40) // must be >= the trailing inset
                        .padding(.bottom, -40) // must be >= the bottom inset
                )
                .listRowBackground(
                    Color(UIColor.secondarySystemGroupedBackground)
                        .overlay(alignment: .top) {
                            Divider()
                        }
                        .overlay(alignment: .bottom) {
                            Divider()
                        }
                )
                
                switch commentState {
                case .Loading:
                    VStack {
                        ProgressView()
                        Text("Fetching comments")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                case .Failure:
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                        Text("Failed to load comments")
                    }
                case .Success:
                    ForEach(comments) { comment in
                        Text(comment.comment_plain)
                    }
                }
            }
        }.navigationBarTitle("", displayMode: .inline)
            .listStyle(.inset)
            .onAppear {
                let userProfile = "\(baseUrl)/u/\(post.submitter_user.username)"
                createdAt = formatDateToHumanReadableDuration(date:post.created_at) ?? ""
                byLine = "by [\(post.submitter_user.username)](\(userProfile))"
                
                let postUrl = "\(post.short_id_url).json"
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let url = URL(string: postUrl) {
                        if let data = try? Data(contentsOf: url) {
                            let commentParser = JSONParser()
                            commentParser.parse(of: Story.self, from: data) { result in
                                switch result {
                                case .failure(_):
                                    commentState = .Failure
                                case let .success(story):
                                    comments = story.comments
                                    commentState = .Success
                                    
                                    print(comments)
                                }
                            }
                            return
                        }
                    }
                    
                    commentState = .Failure
                }
            }
    }
}

#Preview {
    PostDetailView(
        post: Post(short_id: "test1d", short_id_url: "https://lobste.rs/s/test1d", created_at: DateFormatter().date(from: "2023-12-12T09:19:38.000-06:00") ?? Date.now, title: "test title", url: "https://example.com", score: 14, flags: 0, comment_count: 5, description: "description goes here", description_plain: "description_plain goes here", comments_url: "https://lobste.rs/s/test1d/test_title", submitter_user: User(username: "userName", created_at: DateFormatter().date(from: "2020-01-20T08:00:08.000-06:00") ?? Date.now, is_admin: false, about: "bio", is_moderator: false, karma: 100, avatar_url: "/avatars/avatar.png", invited_by_user: "someOtherUser"), user_is_author: false, tags: ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"])
    )
}
