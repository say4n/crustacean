//
//  ContentView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

enum TabType: String {
    case hottest = "Trending"
    case active = "Active"
    case newest = "Newest"
}

struct Tab: Hashable {
    let name: TabType
    let icon: String
}

struct ContentView: View {
    let tabs = [
        Tab(name: .hottest, icon: "flame"),
        Tab(name: .active, icon: "popcorn"),
        Tab(name: .newest, icon: "mail.stack"),
    ]

    @State private var selectedTab = TabType.hottest.rawValue

    private let dataSource = TabDataSource.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.self) { tab in
                NavigationView {
                    DataTabView(tabType: tab.name)
                        .navigationTitle(selectedTab)
                }
                .tabItem {
                    Label(tab.name.rawValue, systemImage: tab.icon)
                }
                .tag(tab.name.rawValue)
            }
        }.onAppear {
            Task {
                // Pre-fetch tab data.
                await (dataSource.fetchData(for: .hottest), dataSource.fetchData(for: .active), dataSource.fetchData(for: .newest))
            }
        }
    }
}

#Preview {
    ContentView()
}
