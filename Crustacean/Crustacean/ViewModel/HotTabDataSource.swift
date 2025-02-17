//
//  HotTabDataSource.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation
import OSLog

@MainActor final class HotTabDataSource: @preconcurrency DataSource, ObservableObject {
    static var shared: HotTabDataSource = .init()
    @Published var items = [Post]()
    @Published var state: DataSourceState = .unknown

    private var page: Int = 0
    private var endpoint: URL {
        BASE_URL.appending(path: "page/\(page).json")
    }

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HotTabDataSource")

    public func fetchData(cursor: Int = 0) async {
        if state == .loading {
            return
        }

        if items.count - cursor > 10 {
            return
        } else {
            DispatchQueue.main.async {
                self.page += 1
            }
        }

        DispatchQueue.main.async {
            self.state = .loading
        }

        do {
            let fetchedItems = try await fetchHotPosts()
            let _page = page
            logger.info("Fetched \(fetchedItems.count) hot posts in page \(_page)")

            DispatchQueue.main.async {
                self.items.append(contentsOf: fetchedItems)
            }
        } catch {
            logger.error("Failed to fetch hot posts")
            DispatchQueue.main.async {
                self.state = .error
            }
        }
    }

    private func fetchHotPosts() async throws -> [Post] {
        do {
            let data = try await fetchDataFromURL(endpoint)
            let decodedData = try JSONDecoder().decode([Post].self, from: data)
            state = .loaded

            return decodedData
        } catch {
            logger.error("Failed to decode JSON: \(error)")
            state = .error
            return []
        }
    }
}
