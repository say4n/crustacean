//
//  LoginSheet.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/08/2025.
//

import SwiftUI

struct LoginSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://lobste.rs/login")!, showLoginView: $isPresented)
                .ignoresSafeArea(.all)
                .navigationTitle("Login with Lobste.rs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
        }
    }
}