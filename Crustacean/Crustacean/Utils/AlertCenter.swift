//
//  AlertCenter.swift
//  Crustacean
//
//  Created by Sayan Goswami on 24/08/2025.
//

import SwiftUI

/// App-wide channel for transient error messages, surfaced as toasts by the
/// root `ContentView`. Action handlers can report failures without each of
/// them owning its own alert state.
@MainActor
final class AlertCenter: ObservableObject {
    static let shared = AlertCenter()

    @Published var message: String? = nil

    func present(_ message: String) {
        self.message = message
    }
}