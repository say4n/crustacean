//
//  DataTabView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

struct DataTabView: View {
    let tabType: TabType
    @ObservedObject var dataSource = TabDataSource()

    var body: some View {
        ScrollView {
            LazyVStack {
                let items = dataSource.items[tabType] ?? []

                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    PostItemView(data: item)
                        .onAppear {
                            Task {
                                await dataSource.fetchData(for: tabType, cursor: index)
                            }
                        }
                }
            }.onAppear {
                Task {
                    await dataSource.fetchData(for: tabType)
                }
            }
        }
    }
}

#Preview {
    DataTabView(tabType: TabType.hottest)
}
