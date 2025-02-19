//
//  FetchUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Network
import OSLog
import UIKit

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FetchUtils")

class NetworkUtils {
    static let shared = NetworkUtils()

    private var nm = NWPathMonitor()

    var isConnected: Bool {
        nm.currentPath.status == .satisfied
    }
}

func fetchDataFromURL(_ url: URL) async throws -> Data {
    var request = URLRequest(url: url)
    let networkState = NetworkUtils.shared

    let versionString = Bundle.main.releaseVersionNumber ?? "Unknown"
    let userAgent = "Crusacean/\(versionString) (\(await UIDevice.current.model); iOS \(await UIDevice.current.systemVersion); https://optionalstudio.work)"

    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.timeoutInterval = 10

    if networkState.isConnected {
        logger.info("Network link up, fetching data from lobste.rs")
        request.cachePolicy = .reloadRevalidatingCacheData
    } else {
        logger.info("Network link down, using cached data")
        request.cachePolicy = .returnCacheDataDontLoad
    }

    let (data, _) = try await URLSession.shared.data(for: request)

    return data
}
