//
//  HotTabView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

struct HotTabView: View {
    @ObservedObject var dataSource = HotTabDataSource()

    var body: some View {
        ScrollView {
            LazyVStack {
                if [DataSourceState.unknown, DataSourceState.loading].contains(dataSource.state) {
                    ProgressView()
                        .task {
                            await dataSource.fetchData()
                        }
                }

                ForEach(Array(zip($dataSource.items.indices, dataSource.items)), id: \.0) { index, item in
                    PostItemView(data: item)
                        .onAppear {
                            Task {
                                await dataSource.fetchData(cursor: index)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    HotTabView()
}
