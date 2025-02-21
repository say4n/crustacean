//
//  Post.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

struct Post: Decodable {
    let commentCount: Int
    let commentsUrl: String
    let createdAt: String
    let description: String
    let descriptionPlain: String
    let flags: Int
    var score: Int
    let shortId: String
    let shortIdUrl: String
    let submitterUser: String
    let tags: [String]
    let title: String
    let url: String
    let userIsAuthor: Bool
}

extension Post {
    enum CodingKeys: String, CodingKey {
        case description, title, url, tags, flags, score
        case commentCount = "comment_count"
        case commentsUrl = "comments_url"
        case createdAt = "created_at"
        case descriptionPlain = "description_plain"
        case shortIdUrl = "short_id_url"
        case shortId = "short_id"
        case submitterUser = "submitter_user"
        case userIsAuthor = "user_is_author"
    }
}
