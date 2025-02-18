//
//  Comment.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Foundation

struct Comment: Decodable {
    let comment: String
    let commentPlain: String
    let commentingUser: String
    let createdAt: String
    let depth: Int
    let flags: Int
    let isDeleted: Bool
    let isModerated: Bool
    let lastEditedAt: String
    let parentComment: String
    let score: Int
    let shortId: String
    let shortIdUrl: String
    let url: String
}

extension Comment {
    enum CodingKeys: String, CodingKey {
        case comment = "comment"
        case commentPlain = "comment_plain"
        case commentingUser = "commenting_user"
        case createdAt = "created_at"
        case depth = "depth"
        case flags = "flags"
        case isDeleted = "is_deleted"
        case isModerated = "is_moderated"
        case lastEditedAt = "last_edited_at"
        case parentComment = "parent_comment"
        case score = "score"
        case shortId = "short_id"
        case shortIdUrl = "short_id_url"
        case url = "url"
    }
}
