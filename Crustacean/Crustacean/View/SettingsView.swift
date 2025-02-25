//
//  SettingsView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 20/02/2025.
//

import AlertToast
import OSLog
import SwiftUI
import WebKit

enum Appearance: String, CaseIterable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"
}

func nukeCookies() {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    logger.info("Cookie storage cleared")
}

struct SettingsView: View {
    @AppStorage("appAppearance") private var appAppearance: Appearance = .automatic
    @AppStorage("defaultTab") private var defaultTab: TabType = .hottest
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("demoMode") private var demoMode = false

    @Environment(\.openURL) private var openURL

    private let tabOptions = TabType.allCases.filter { $0 != .settings }
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsView")

    @State private var showLoginView = false
    @State private var showDemoModeAlert = false

    private func getLoginState() -> Bool {
        return HTTPCookieStorage.shared.cookies?.filter { $0.name == "lobster_trap" }.count ?? 0 > 0
    }

    var body: some View {
        Form {
            Section {
                if !isLoggedIn || !demoMode {
                    Button {
                        showLoginView = true
                    } label: {
                        Label("Login to Lobste.rs", systemImage: "person.crop.circle")
                    }
                } else {
                    Button(role: .destructive) {
                        nukeCookies()

                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            for record in records {
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                                logger.info("Cookie \(record) deleted")
                            }
                        }

                        isLoggedIn = false
                        demoMode = false
                    } label: {
                        Label(demoMode ? "Logout (Demo Mode)" : "Logout", systemImage: "person.crop.circle")
                            .foregroundStyle(.red)
                    }
                }
            } header: {
                Text("Account")
            } footer: {
                Text("Login opens a browser window to Lobste.rs for you to login. Once you're logged in, your credentials are stored locally on your device.")
            }

            Section {
                Picker(selection: $appAppearance) {
                    ForEach(Appearance.allCases, id: \.self) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance)
                    }
                } label: {
                    Label("Theme", systemImage: "paintpalette")
                }

                Picker(selection: $defaultTab) {
                    ForEach(tabOptions, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                } label: {
                    Label("Default Tab", systemImage: "square.stack.3d.up")
                }
            } header: {
                Text("Preferences")
            }

            Section {
                Button {
                    openURL(URL(string: "https://lobste.rs/about")!)
                } label: {
                    Label("Terms of Service (Lobste.rs)", systemImage: "text.document")
                }

                Button {
                    openURL(URL(string: "https://crustacean.optionalstudio.work")!)
                } label: {
                    Label("Support", systemImage: "ladybug")
                }

                NavigationLink {
                    VStack {
                        Spacer()

                        Image("Icon")
                            .resizable()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 4)
                            )
                            .frame(width: 128, height: 128)
                            .simultaneousGesture(TapGesture(count: 5).onEnded {
                                demoMode.toggle()
                                showDemoModeAlert = true
                            })
                            .sensoryFeedback(.success, trigger: demoMode)

                        HStack(spacing: 4) {
                            Text("Crustacean")
                            Text("(v\(Bundle.main.releaseVersionNumber ?? "0"))")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .toast(isPresenting: $showDemoModeAlert) {
                        AlertToast(
                            displayMode: .banner(.slide),
                            type: demoMode ? .complete(.green) : .regular,
                            title: "Demo mode \(demoMode ? "enabled" : "disabled")"
                        )
                    }
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            } header: {
                Text("Information")
            }
        }
        .sheet(isPresented: $showLoginView) {
            NavigationStack {
                WebView(url: URL(string: "https://lobste.rs/login")!, showLoginView: $showLoginView)
                    .ignoresSafeArea(.all)
                    .navigationTitle("Login with Lobste.rs")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cancel") {
                                showLoginView = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            isLoggedIn = getLoginState()
        }
    }
}

#Preview {
    SettingsView()
}
