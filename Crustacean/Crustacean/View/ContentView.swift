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

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    HStack {
                        DataTabView(tabType: tab.name)
                    }
                    .tabItem {
                        Label(tab.name.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab.name.rawValue)
                }
            }.navigationTitle(selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
