//
//  Post.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import Foundation

class Post: Codable, Identifiable {
    var short_id: String
    var short_id_url: String
    var created_at: Date
    var title: String
    var url: String
    var score: Int
    var flags: Int
    var comment_count: Int
    var description: String
    var description_plain: String
    var comments_url: String
    var submitter_user: User
    var user_is_author: Bool
    var tags: [String]
    
    init(short_id: String, short_id_url: String, created_at: Date, title: String, url: String, score: Int, flags: Int, comment_count: Int, description: String, description_plain: String, comments_url: String, submitter_user: User, user_is_author: Bool, tags: [String]) {
        self.short_id = short_id
        self.short_id_url = short_id_url
        self.created_at = created_at
        self.title = title
        self.url = url
        self.score = score
        self.flags = flags
        self.comment_count = comment_count
        self.description = description
        self.description_plain = description_plain
        self.comments_url = comments_url
        self.submitter_user = submitter_user
        self.user_is_author = user_is_author
        self.tags = tags
    }
}
