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
        let items = dataSource.items[tabType] ?? []

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
        }.onAppear {
            Task {
                await dataSource.fetchData(for: tabType)
            }
        }
    }
}

#Preview {
    DataTabView(tabType: TabType.hottest)
}
