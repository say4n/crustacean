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
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("demoMode") private var demoMode = false

    @State private var selectedTab: TabType = .hottest
    @State private var showSessionExpiredAlert = false
    @State private var showLoginView = false
    @State private var didRunSessionCheck = false

    private let dataSource = TabDataSource.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.self) { tab in
                NavigationStack {
                    if tab.name == .settings {
                        SettingsView()
                            .navigationTitle(tab.name.rawValue)
                            .navigationBarTitleDisplayMode(.inline)
                    } else {
                        DataTabView(tabType: tab.name)
                            .navigationTitle(tab.name.rawValue)
                            .navigationBarTitleDisplayMode(.large)
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
                await(dataSource.fetchData(for: .hottest), dataSource.fetchData(for: .active), dataSource.fetchData(for: .newest))
            }
        }
        .task {
            await checkSessionOnLaunch()
        }
        .alert("Session expired", isPresented: $showSessionExpiredAlert) {
            Button("Log in again") {
                showLoginView = true
            }
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text("Your Lobste.rs session has expired. Log in again to vote and comment.")
        }
        .sheet(isPresented: $showLoginView) {
            LoginSheet(isPresented: $showLoginView)
        }
    }

    private func checkSessionOnLaunch() async {
        guard !didRunSessionCheck else { return }
        didRunSessionCheck = true

        // Only logged-in sessions need validating, and demo mode has no session.
        guard isLoggedIn, !demoMode else { return }

        let state = await currentSessionState()
        guard state == .loggedOut else { return }

        isLoggedIn = false
        resetCSRFTokenCache()
        showSessionExpiredAlert = true
    }
}

#Preview {
    ContentView()
}
