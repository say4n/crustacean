//
//  ContentView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

struct Tab: Hashable {
    let name: String
    let icon: String
}

struct ContentView: View {
    let tabs = [
        Tab(name: "Hottest", icon: "flame"),
        Tab(name: "Active", icon: "popcorn"),
        Tab(name: "Newest", icon: "mail.stack"),
    ]
    
    @State private var selectedTab = "Hottest"
    
    var body: some View {
        NavigationView {
            TabView (selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab.name)
                        .tabItem {
                            Label(tab.name, systemImage: tab.icon)
                        }
                        .tag(tab.name)
                }
            }.navigationTitle(selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
