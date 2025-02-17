//
//  BundleExtensions.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
