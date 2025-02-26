//
//  Comment.swift
//  Crustacean
//
//  Created by Sayan Goswami on 18/02/2025.
//

import Foundation

struct CommentWrapper: Decodable {
    let comments: [Comment]
}

class Comment: Decodable {
    let comment: String
    let commentPlain: String
    let commentingUser: String
    let createdAt: String
    let depth: Int
    let flags: Int
    let isDeleted: Bool
    let isModerated: Bool
    let lastEditedAt: String
    let parentComment: String?
    var score: Int
    let shortId: String
    let shortIdUrl: String
    let url: String

    var children: [Comment] = []
    var isHidden: Bool = false

    init(comment: String, commentPlain: String, commentingUser: String, createdAt: String, depth: Int, flags: Int, isDeleted: Bool, isModerated: Bool, lastEditedAt: String, parentComment: String?, score: Int, shortId: String, shortIdUrl: String, url: String, children: [Comment]) {
        self.comment = comment
        self.commentPlain = commentPlain
        self.commentingUser = commentingUser
        self.createdAt = createdAt
        self.depth = depth
        self.flags = flags
        self.isDeleted = isDeleted
        self.isModerated = isModerated
        self.lastEditedAt = lastEditedAt
        self.parentComment = parentComment
        self.score = score
        self.shortId = shortId
        self.shortIdUrl = shortIdUrl
        self.url = url
        self.children = children
    }

    static func getNullComment() -> Comment {
        return Comment(
            comment: "",
            commentPlain: "",
            commentingUser: "",
            createdAt: "",
            depth: -1,
            flags: -1,
            isDeleted: false,
            isModerated: false,
            lastEditedAt: "",
            parentComment: nil,
            score: -1,
            shortId: "",
            shortIdUrl: "",
            url: "",
            children: []
        )
    }
}

extension Comment {
    enum CodingKeys: String, CodingKey {
        case comment
        case commentPlain = "comment_plain"
        case commentingUser = "commenting_user"
        case createdAt = "created_at"
        case depth
        case flags
        case isDeleted = "is_deleted"
        case isModerated = "is_moderated"
        case lastEditedAt = "last_edited_at"
        case parentComment = "parent_comment"
        case score
        case shortId = "short_id"
        case shortIdUrl = "short_id_url"
        case url
    }
}
