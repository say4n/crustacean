//
//  CrustaceanApp.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import SwiftUI

@main
struct CrustaceanApp: App {
    let networkState = NetworkUtils.shared

    @AppStorage("appAppearance") var appAppearance: Appearance = .automatic

    private func colorScheme() -> ColorScheme? {
        switch appAppearance {
        case Appearance.automatic: return nil
        case Appearance.light: return .light
        case Appearance.dark: return .dark
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme())
        }
    }
}
