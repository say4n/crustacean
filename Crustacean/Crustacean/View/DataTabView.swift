//
//  DataTabView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

struct DataTabView: View {
    let tabType: TabType
    @ObservedObject var dataSource = TabDataSource.shared
    @ObservedObject var networkState = NetworkUtils.shared

    @State var taskId: UUID = .init()

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

                ScrollView {
                    LazyVStack {
                        ForEach(items.indices, id: \.self) { index in
                            PostItemView(data: items[index])
                                .onAppear {
                                    Task {
                                        await dataSource.fetchData(for: tabType, cursor: index)
                                    }
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
