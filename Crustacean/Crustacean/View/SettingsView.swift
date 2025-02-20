//
//  SettingsView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 20/02/2025.
//

import SwiftUI

enum Appearance: String, CaseIterable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"
}

struct SettingsView: View {
    @AppStorage("appAppearance") var appAppearance: Appearance = .automatic
    @AppStorage("defaultTab") var defaultTab: TabType = .hottest

    private let tabOptions = TabType.allCases.filter { $0 != .settings }

    var body: some View {
        Form {
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
            } header: {
                Text("Information")
            }
        }
    }
}

#Preview {
    SettingsView()
}
