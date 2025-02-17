//
//  FetchUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import UIKit

func fetchDataFromURL(_ url: URL) async throws -> Data {
    var request = URLRequest(url: url)

    let versionString = Bundle.main.releaseVersionNumber ?? "Unknown"
    let userAgent = "Crusacean/\(versionString) (\(await UIDevice.current.model); iOS \(await UIDevice.current.systemVersion); https://optionalstudio.work)"

    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.timeoutInterval = 10
    request.cachePolicy = .reloadRevalidatingCacheData

    let (data, _) = try await URLSession.shared.data(for: request)

    return data
}
