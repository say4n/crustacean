//
//  LocalFilter.swift
//  Crustacean
//
//  Created by Sayan Goswami on 25/02/2025.
//

import SwiftData

@Model
class FilteredPostItem {
    @Attribute(.unique) var shortId: String

    init(shortId: String) {
        self.shortId = shortId
    }
}

@Model
class FilteredCommentItem {
    @Attribute(.unique) var shortId: String

    init(shortId: String) {
        self.shortId = shortId
    }
}

@Model
class FilteredPerson {
    @Attribute(.unique) var username: String

    init(username: String) {
        self.username = username
    }
}
