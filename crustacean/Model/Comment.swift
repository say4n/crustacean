//
//  Comment.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import Foundation

class Comment: Codable, Identifiable {
    var short_id: String
    var short_id_url: String
    var created_at: Date
    var updated_at: Date
    var is_deleted: Bool
    var is_moderated: Bool
    var score: Int
    var flags: Int
    var parent_comment: String?
    var comment: String
    var comment_plain: String
    var url: String
    var depth: Int
    var commenting_user: User
    
    init(short_id: String, short_id_url: String, created_at: Date, updated_at: Date, is_deleted: Bool, is_moderated: Bool, score: Int, flags: Int, parent_comment: String, comment: String, comment_plain: String, url: String, depth: Int, commenting_user: User) {
        self.short_id = short_id
        self.short_id_url = short_id_url
        self.created_at = created_at
        self.updated_at = updated_at
        self.is_deleted = is_deleted
        self.is_moderated = is_moderated
        self.score = score
        self.flags = flags
        self.parent_comment = parent_comment
        self.comment = comment
        self.comment_plain = comment_plain
        self.url = url
        self.depth = depth
        self.commenting_user = commenting_user
    }
}
