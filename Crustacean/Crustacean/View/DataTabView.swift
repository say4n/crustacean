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

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
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
                            .if(isLoggedIn) { view in
                                view.swipeActions(edge: .trailing) {
                                    let post: Post = items[index]

                                    Button {
                                        logger.info("Upvote")
                                        Task {
                                            if dataSource.items[tabType]?[index].isUpvoted == true {
                                                return
                                            }

                                            if let voteResponse = await castVote(shortId: post.shortId, entity: .stories, action: .upvote), voteResponse == .success {
                                                dataSource.items[tabType]?[index].isUpvoted = true
                                                dataSource.items[tabType]?[index].score += 1
                                            }
                                        }
                                    } label: {
                                        Label("Upvote", systemImage: "arrowshape.up.fill")
                                    }
                                    .tint(.green)

                                    Button {
                                        logger.info("Unvote")
                                        Task {
                                            if dataSource.items[tabType]?[index].isUpvoted == false {
                                                return
                                            }

                                            if let voteResponse = await castVote(shortId: post.shortId, entity: .stories, action: .unvote), voteResponse == .success {
                                                dataSource.items[tabType]?[index].isUpvoted = false
                                                dataSource.items[tabType]?[index].score -= 1
                                            }
                                        }
                                    } label: {
                                        Label("Unvote", image: "Unvote")
                                    }
                                    .tint(.red)

                                    Button {
                                        logger.info("Flag")
                                        Task {}
                                    } label: {
                                        Label("Flag", systemImage: "ellipsis.circle")
                                    }
                                    .tint(.gray)
                                }
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
