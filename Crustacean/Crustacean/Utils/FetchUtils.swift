//
//  FetchUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Network
import OSLog
import SwiftUI
import UIKit

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FetchUtils")

class NetworkUtils: ObservableObject {
    static let shared = NetworkUtils()
    @Published var isNetworkAvailable = false

    private let nm = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkUtils")

    init() {
        nm.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                logger.info("\(path.debugDescription)")

                withAnimation {
                    if path.status == .satisfied {
                        self.isNetworkAvailable = true
                    } else {
                        self.isNetworkAvailable = false
                    }
                }
            }
        }

        nm.start(queue: queue)
    }
}

func fetchDataFromURL(_ url: URL, httpMethod: String? = nil) async throws -> Data {
    var request = URLRequest(url: url)
    let networkState = NetworkUtils.shared

    let versionString = Bundle.main.releaseVersionNumber ?? "Unknown"
    let userAgent = "Crustacean/\(versionString) (\(await UIDevice.current.model); iOS \(await UIDevice.current.systemVersion); https://crustacean.optionalstudio.work)"

    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.timeoutInterval = 10
    if let httpMethod = httpMethod {
        request.httpMethod = httpMethod
    }

    if networkState.isNetworkAvailable {
        logger.info("Network link up, fetching data from lobste.rs")
        request.cachePolicy = .reloadRevalidatingCacheData
    } else {
        logger.info("Network link down, using cached data")
        request.cachePolicy = .returnCacheDataDontLoad
    }

    let (data, _) = try await URLSession.shared.data(for: request)

    HTTPCookieStorage.shared.cookies?.forEach { cookie in
        logger.info("Cookie `\(cookie.name)` expires on \(cookie.expiresDate?.description ?? "UNKNOWN")")
    }

    return data
}
