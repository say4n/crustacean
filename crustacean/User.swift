//
//  User.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import Foundation

struct User: Codable {
    var username: String
    var created_at: Date
    var is_admin: Bool
    var about: String
    var is_moderator: Bool
    var karma: Int
    var avatar_url: String
    var invited_by_user: String
    var github_username: String?
    var twitter_username: String?
    
    init(username: String, created_at: Date, is_admin: Bool, about: String, is_moderator: Bool, karma: Int, avatar_url: String, invited_by_user: String, github_username: String? = nil, twitter_username: String? = nil) {
        self.username = username
        self.created_at = created_at
        self.is_admin = is_admin
        self.about = about
        self.is_moderator = is_moderator
        self.karma = karma
        self.avatar_url = avatar_url
        self.invited_by_user = invited_by_user
        self.github_username = github_username
        self.twitter_username = twitter_username
    }
}
