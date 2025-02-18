//
//  DateExtensions.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    static func parseISO(from timestamp: String) -> Date? {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return RFC3339DateFormatter.date(from: timestamp)
    }
}
