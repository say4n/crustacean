//
//  ContentView.swift
//  crustacean
//
//  Created by Sayan Goswami on 21/12/2023.
//

import SwiftUI

struct ContentView: View {
//    var posts    
    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                CrustaceanTabView(tab: tab)
                    .tabItem {
                        Label(tab.tabName, systemImage: tab.tabIcon)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
