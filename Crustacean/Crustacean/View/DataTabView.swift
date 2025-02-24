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

    @State private var taskId: UUID = .init()
    @State private var showFlagAlert = false
    @State private var selectedPostShortId: String? = nil

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
                                        Task {
                                            logger.info("Flag")
                                            selectedPostShortId = post.shortId
                                            showFlagAlert = true
                                        }
                                    } label: {
                                        Label("Flag", systemImage: "ellipsis.circle")
                                    }
                                    .tint(.gray)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .alert("Flag", isPresented: $showFlagAlert) {
                    ForEach(StoryFlagReasons.allCases) { reason in
                        Button(reason.rawValue) {
                            Task {
                                if selectedPostShortId != nil {
                                    let _ = await flagItem(shortId: selectedPostShortId!, entity: .stories, reason: reason)
                                }
                            }
                        }
                    }

                    Button("Cancel", role: .cancel) {
                        Task {
                            if selectedPostShortId != nil {
                                let _ = await castVote(shortId: selectedPostShortId!, entity: .stories, action: .unvote)
                            }
                        }
                    }
                }
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
