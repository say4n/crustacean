//
//  CommentView.swift
//  crustacean
//
//  Created by Sayan Goswami on 23/12/2023.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    
    @State private var createdAt = ""
    @State private var updatedAt = ""
    @State private var userName = ""
    @State private var userProfile = ""
    @State private var byLine = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(.init(comment.comment_plain))
                .font(.body)
            
            HStack {
                Text(.init(byLine))
                
                Spacer()
                
                Label("\(comment.score)", systemImage: "arrow.up.circle")
                    .labelStyle(.titleAndIcon)
                
                Label(createdAt, systemImage: "clock")
                    .labelStyle(.titleAndIcon)
                
                if !updatedAt.isEmpty && updatedAt != createdAt {
                    Label(updatedAt, systemImage: "pencil")
                        .labelStyle(.titleAndIcon)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }.onAppear {
            createdAt = formatDateToHumanReadableDuration(date:comment.created_at) ?? ""
            updatedAt = formatDateToHumanReadableDuration(date:comment.updated_at) ?? ""
            userName = comment.commenting_user.username
            userProfile = "\(baseUrl)/u/\(userName)"
            byLine = "by [\(userName)](\(userProfile))"
        }
    }
}

#Preview {
    CommentView(
        comment: Comment(short_id: "short_id", short_id_url: "short_id_url", created_at: Date.now, updated_at: Date.now, is_deleted: false, is_moderated: false, score: 10, flags: 0, parent_comment: "parent_comment", comment: "comment", comment_plain: "comment_plain", url: "url", depth: 0, commenting_user: User(username: "username", created_at: Date.now, is_admin: false, about: "about", is_moderator: false, karma: 100, avatar_url: "avatar_url", invited_by_user: "invited_by_user"))
    )
}
