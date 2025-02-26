//
//  TabDataSource.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation
import OSLog
import SwiftData

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

    private let container = try? ModelContainer(for: FilteredPostItem.self, FilteredCommentItem.self, FilteredPerson.self)
    private var context: ModelContext? {
        container?.mainContext
    }

    private let hiddenUsersFetchDescriptor = FetchDescriptor<FilteredPerson>()
    private let hiddenStoriesFetchDescriptor = FetchDescriptor<FilteredPostItem>()
    private var hiddenUsers: [String] {
        do {
            return try context?.fetch(hiddenUsersFetchDescriptor).map { $0.username } ?? []
        } catch {
            return []
        }
    }

    private var hiddenPosts: [String] {
        do {
            return try context?.fetch(hiddenStoriesFetchDescriptor).map { $0.shortId } ?? []
        } catch {
            return []
        }
    }

    private var pageByTab: [TabType: Int] = [
        TabType.hottest: 1,
        TabType.active: 1,
        TabType.newest: 1,
    ]

    private func getEndpoint(for tabType: TabType, pageIndex: Int = 1) -> URL {
        return switch tabType {
        case .hottest: BASE_URL.appending(path: "page/\(pageIndex).json")
        case .active: BASE_URL.appending(path: "active/page/\(pageIndex).json")
        case .newest: BASE_URL.appending(path: "newest/page/\(pageIndex).json")
        case .settings: fatalError("Not implemented")
        }
    }

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TabDataSource")

    public func fetchData(for tabType: TabType, cursor: Int = 0, force: Bool = false) async {
        if state[tabType] == .loading {
            return
        }

        if items[tabType]!.count - cursor > 10 && !force {
            return
        }

        DispatchQueue.main.async {
            self.state[tabType] = .loading
        }

        do {
            var fetchedItems = [Post]()

            if force {
                let pageRangeToRefresh = 1 ... (pageByTab[tabType] ?? 1)
                for pageIndex in pageRangeToRefresh {
                    let fetchedItemsByPage = try await fetchHotPosts(for: tabType, pageIndex: pageIndex)
                    fetchedItems.append(contentsOf: fetchedItemsByPage)
                }
            } else {
                fetchedItems = try await fetchHotPosts(for: tabType, pageIndex: pageByTab[tabType] ?? 1)
            }

            fetchedItems = filterHiddenEntities(postsToFilter: fetchedItems)

            let _page = pageByTab[tabType] ?? -1
            logger.info("Fetched \(fetchedItems.count) \(tabType.rawValue) posts in page \(_page)")

            DispatchQueue.main.async {
                self.items[tabType] = self.filterHiddenEntities(postsToFilter: self.items[tabType] ?? [])
                let existingPostIds = self.items[tabType]?.map { $0.shortId }
                let filteredItems: [Post] = fetchedItems.filter { existingPostIds?.contains($0.shortId) != true }

                if !force {
                    self.logger.info("Appended \(filteredItems.count) \(tabType.rawValue) posts in page \(_page)")
                    self.items[tabType]?.append(contentsOf: filteredItems)
                } else {
                    self.logger.info("Updated \(fetchedItems.count) \(tabType.rawValue) posts in page \(_page)")
                    self.items[tabType] = fetchedItems
                }

                self.pageByTab[tabType] = (self.pageByTab[tabType] ?? 1) + (force ? 0 : 1)
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

    private func filterHiddenEntities(postsToFilter: [Post]) -> [Post] {
        return postsToFilter.filter {
            let filterClause = !hiddenPosts.contains($0.shortId)

            if !filterClause {
                logger.warning("\($0.shortId) filtered out")
            }

            return filterClause
        }.filter {
            let filterClause = !hiddenUsers.contains($0.submitterUser)

            if !filterClause {
                logger.warning("\($0.submitterUser) filtered out")
            }

            return filterClause
        }
    }

    private func fetchHotPosts(for tabType: TabType, pageIndex: Int) async throws -> [Post] {
        do {
            let endpoint = getEndpoint(for: tabType, pageIndex: pageIndex)
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
