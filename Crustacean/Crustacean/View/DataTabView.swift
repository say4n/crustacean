//
//  DataTabView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import OSLog
import SwiftUI

struct DataTabView: View {
    let tabType: TabType
    @ObservedObject var dataSource = TabDataSource.shared
    @ObservedObject var networkState = NetworkUtils.shared

    @State var taskId: UUID = .init()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataTabView")

    var body: some View {
        let items = dataSource.items[tabType] ?? []

        ZStack(alignment: .top) {
            VStack {
                if dataSource.state[tabType] == .error && networkState.isNetworkAvailable {
                    Text("Error loading posts, please try again later.")
                }

                if !networkState.isNetworkAvailable && dataSource.state[tabType] != .unknown {
                    Text("Network offline, using cached data.")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.red)
                        .clipped()
                        .transition(.slide)
                }

                List {
                    ForEach(items.indices, id: \.self) { index in
                        PostItemView(data: items[index])
                            .onAppear {
                                Task {
                                    await dataSource.fetchData(for: tabType, cursor: index)
                                }
                            }
                            .swipeActions {
                                let post: Post = items[index]

                                Button {
                                    logger.info("Upvote")
                                    Task {
                                        let upvoteURL = BASE_URL.appending(path: "/stories/\(post.shortId)/upvote")
                                        do {
                                            let response = try await fetchDataFromURL(upvoteURL, httpMethod: "POST")
                                            logger.info("Response from upvote: \(String(data: response, encoding: .utf8) ?? "UNKNOWN")")
                                        } catch {
                                            logger.error("Could not upvote story: \(error)")
                                        }
                                    }
                                } label: {
                                    Label("Upvote", systemImage: "arrowshape.up.fill")
                                }
                                .tint(.green)

                                Button {
                                    logger.info("Unvote")
                                    Task {
                                        let unvoteURL = BASE_URL.appending(path: "/stories/\(post.shortId)/unvote")
                                        do {
                                            let response = try await fetchDataFromURL(unvoteURL, httpMethod: "POST")
                                            logger.info("Response from unvote: \(String(data: response, encoding: .utf8) ?? "UNKNOWN")")
                                        } catch {
                                            logger.error("Could not unvote story: \(error)")
                                        }
                                    }
                                } label: {
                                    Label("Unvote", systemImage: "arrowshape.up")
                                }
                                .tint(.red)
                            }
                    }
                }
                .listStyle(.plain)
            }
            .refreshable {
                taskId = .init()
            }
        }.task(id: taskId) {
            await dataSource.fetchData(for: tabType, force: true)
        }
    }
}

#Preview {
    DataTabView(tabType: TabType.hottest)
}
