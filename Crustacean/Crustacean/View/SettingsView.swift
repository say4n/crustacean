//
//  SettingsView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 20/02/2025.
//

import OSLog
import SwiftUI
import WebKit

enum Appearance: String, CaseIterable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"
}

struct SettingsView: View {
    @AppStorage("appAppearance") private var appAppearance: Appearance = .automatic
    @AppStorage("defaultTab") private var defaultTab: TabType = .hottest
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.openURL) var openURL

    private let tabOptions = TabType.allCases.filter { $0 != .settings }
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsView")

    @State private var showLoginView = false

    private func getLoginState() -> Bool {
        return HTTPCookieStorage.shared.cookies?.filter { $0.name == "lobster_trap" }.count ?? 0 > 0
    }

    var body: some View {
        Form {
            Section {
                if !isLoggedIn {
                    Button("Login to Lobste.rs") {
                        showLoginView = true
                    }
                } else {
                    Button("Logout", role: .destructive) {
                        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                        logger.info("Cookie storage cleared")

                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            for record in records {
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                                logger.info("Cookie \(record) deleted")
                            }
                        }

                        isLoggedIn = false
                    }
                }
            } header: {
                Text("Account")
            } footer: {
                Text("Login opens a browser window to Lobste.rs for you to login. Once you're logged in, your credentials are stored locally on your device.")
            }

            Section {
                Picker("Theme", selection: $appAppearance) {
                    ForEach(Appearance.allCases, id: \.self) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance)
                    }
                }

                Picker("Default Tab", selection: $defaultTab) {
                    ForEach(tabOptions, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                }
            } header: {
                Text("Preferences")
            }

            Section {
                NavigationLink("About") {
                    VStack {
                        Image("Icon")
                            .resizable()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 4)
                            )
                            .frame(width: 128, height: 128)

                        HStack(spacing: 4) {
                            Text("Crustacean")
                            Text("(v\(Bundle.main.releaseVersionNumber ?? "0"))")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    }
                }

                Button("Support") {
                    openURL(URL(string: "https://crustacean.optionalstudio.work")!)
                }
            } header: {
                Text("Information")
            }
        }
        .sheet(isPresented: $showLoginView) {
            WebView(url: URL(string: "https://lobste.rs/login")!, showLoginView: $showLoginView)
                .ignoresSafeArea(.all)
        }
        .onAppear {
            isLoggedIn = getLoginState()
        }
    }
}

#Preview {
    SettingsView()
}
