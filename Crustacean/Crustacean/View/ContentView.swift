//
//  ContentView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

enum TabType: String, CaseIterable {
    case hottest = "Trending"
    case active = "Active"
    case newest = "Newest"
    case settings = "Settings"
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
        Tab(name: .settings, icon: "gear"),
    ]

    @AppStorage("defaultTab") private var defaultTab = TabType.hottest
    @State private var selectedTab: TabType = .hottest

    private let dataSource = TabDataSource.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.self) { tab in
                NavigationView {
                    if tab.name == .settings {
                        SettingsView()
                            .navigationTitle(tab.name.rawValue)
                    } else {
                        DataTabView(tabType: tab.name)
                            .navigationTitle(tab.name.rawValue)
                    }
                }
                .tabItem {
                    Label(tab.name.rawValue, systemImage: tab.icon)
                }
                .tag(tab.name)
            }
        }.onAppear {
            selectedTab = defaultTab

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
