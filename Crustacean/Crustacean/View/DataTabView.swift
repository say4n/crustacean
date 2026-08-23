//
//  DataTabView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import OSLog
import SwiftData
import SwiftUI

struct DataTabView: View {
    let tabType: TabType

    @Environment(\.modelContext) private var context

    @Query private var filteredUsers: [FilteredPerson]
    @Query private var filteredPosts: [FilteredPostItem]

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("demoMode") private var demoMode = false

    @ObservedObject var dataSource = TabDataSource.shared
    @ObservedObject var networkState = NetworkUtils.shared

    @State private var taskId: UUID = .init()

    @State private var showFlagAlert = false
    @State private var showHideAlert = false

    @State private var selectedPostShortId: String? = nil
    @State private var selectedUsername: String? = nil

    @State private var isHiddenEntity = [String]()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataTabView")

    var body: some View {
        let items = dataSource.items[tabType] ?? []

        VStack(spacing: 0) {
            if dataSource.state[tabType] == .error && networkState.isNetworkAvailable {
                statusBanner(icon: "exclamationmark.triangle.fill", text: "Couldn't load stories. Pull to refresh.", tint: .red)
            }

            if !networkState.isNetworkAvailable && dataSource.state[tabType] != .unknown {
                statusBanner(icon: "wifi.slash", text: "Offline — showing cached stories.", tint: .orange)
            }

            if items.isEmpty {
                ScrollView {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 120)
                }
            } else {
                storyList(items)
            }
        }
        .refreshable {
            taskId = .init()
        }
        .task(id: taskId) {
            await dataSource.fetchData(for: tabType, force: true)
        }
        .onAppear {
            isHiddenEntity = filteredUsers.map { $0.username } + filteredPosts.map { $0.shortId }
        }
    }

    private func storyList(_ items: [Post]) -> some View {
        List {
            ForEach(items.indices.filter {
                !(isHiddenEntity.contains(items[$0].shortId) || isHiddenEntity.contains(items[$0].submitterUser))
            }, id: \.self) { index in
                PostItemView(data: items[index])
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(Color.secondary.opacity(0.25))
                    .onAppear {
                        Task {
                            await dataSource.fetchData(for: tabType, cursor: index)
                        }
                    }
                    .if(isLoggedIn || demoMode) { view in
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
                        .swipeActions(edge: .leading) {
                            let post: Post = items[index]

                            Button {
                                logger.info("Hide")
                                selectedPostShortId = post.shortId
                                selectedUsername = post.submitterUser
                                showHideAlert = true
                            } label: {
                                Label("Hide", systemImage: "eye.slash")
                            }
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

            Button("Cancel", role: .cancel) {}
        }
        .alert("Hide", isPresented: $showHideAlert) {
            Button("Story") {
                if selectedPostShortId != nil {
                    logger.info("Hiding story: \(selectedPostShortId!)")
                    context.insert(FilteredPostItem(shortId: selectedPostShortId!))
                    withAnimation {
                        isHiddenEntity.append(selectedPostShortId!)
                    }
                }
            }
            Button("User") {
                if selectedUsername != nil {
                    logger.info("Hiding user: \(selectedUsername!)")
                    context.insert(FilteredPerson(username: selectedUsername!))
                    withAnimation {
                        isHiddenEntity.append(selectedUsername!)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var emptyState: some View {
        Group {
            switch dataSource.state[tabType] {
            case .loading, .unknown, .none:
                ProgressView("Loading…")
            case .error:
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text("Couldn't load stories")
                        .font(.headline)
                    Text("Pull to refresh to try again.")
                        .font(.subheadline)
                }
            case .loaded:
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                    Text("No stories yet")
                        .font(.headline)
                }
            }
        }
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }

    private func statusBanner(icon: String, text: String, tint: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12))
            .transition(.slide)
    }
}

#Preview {
    DataTabView(tabType: TabType.hottest)
}