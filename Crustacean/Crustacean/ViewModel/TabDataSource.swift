//
//  TabDataSource.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation
import OSLog

@MainActor final class TabDataSource: @preconcurrency DataSource, ObservableObject {
    static var shared: TabDataSource = .init()

    @Published var items: [TabType: [Post]] = [
        TabType.hottest: [],
        TabType.active: [],
        TabType.newest: [],
    ]
    @Published var state: [TabType: DataSourceState] = [
        TabType.hottest: .unknown,
        TabType.active: .unknown,
        TabType.newest: .unknown,
    ]

    private var pageByTab: [TabType: Int] = [
        TabType.hottest: 1,
        TabType.active: 1,
        TabType.newest: 1,
    ]

    private func getEndpoint(for tabType: TabType) -> URL {
        let pageIndex = pageByTab[tabType] ?? 1

        return switch tabType {
        case .hottest: BASE_URL.appending(path: "page/\(pageIndex).json")
        case .active: BASE_URL.appending(path: "active/page/\(pageIndex).json")
        case .newest: BASE_URL.appending(path: "newest/page/\(pageIndex).json")
        }
    }

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TabDataSource")

    public func fetchData(for tabType: TabType, cursor: Int = 0) async {
        if state[tabType] == .loading {
            return
        }

        if items[tabType]!.count - cursor > 10 {
            return
        }

        DispatchQueue.main.async {
            self.state[tabType] = .loading
        }

        do {
            let fetchedItems = try await fetchHotPosts(for: tabType)
            let _page = pageByTab[tabType] ?? -1
            logger.info("Fetched \(fetchedItems.count) \(tabType.rawValue) posts in page \(_page)")

            DispatchQueue.main.async {
                let existingPostIds = self.items[tabType]?.map { $0.shortId }
                let filteredItems: [Post] = fetchedItems.filter { existingPostIds?.contains($0.shortId) != true }

                self.logger.info("Appended \(filteredItems.count) \(tabType.rawValue) posts in page \(_page)")
                self.items[tabType]?.append(contentsOf: filteredItems)

                self.pageByTab[tabType] = (self.pageByTab[tabType] ?? 1) + 1
            }
        } catch {
            logger.error("Failed to fetch \(tabType.rawValue) posts")
            DispatchQueue.main.async {
                self.state[tabType] = .error
            }
        }

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    private func fetchHotPosts(for tabType: TabType) async throws -> [Post] {
        do {
            let endpoint = getEndpoint(for: tabType)
            let data = try await fetchDataFromURL(endpoint)
            let decodedData = try JSONDecoder().decode([Post].self, from: data)

            state[tabType] = .loaded

            return decodedData
        } catch {
            logger.error("Failed to decode JSON: \(error)")

            state[tabType] = .error

            return []
        }
    }
}
