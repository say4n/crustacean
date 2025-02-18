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

    var body: some View {
        let items = dataSource.items[tabType] ?? []

        ZStack(alignment: .top) {
            if [DataSourceState.unknown, DataSourceState.loading].contains(dataSource.state[tabType]) {
                ProgressView()
                    .padding(4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
                    .padding(.top)
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
    }
}

#Preview {
    DataTabView(tabType: TabType.hottest)
}
