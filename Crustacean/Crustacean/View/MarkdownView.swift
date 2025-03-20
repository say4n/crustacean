//
//  MarkdownView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 19/02/2025.
//

import MarkdownUI
import SwiftUI

struct MarkdownView: View {
    let text: String
    let score: Int

    var body: some View {
        Markdown(text)
            .markdownBlockStyle(\.blockquote) { configuration in
                configuration.label
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .markdownTextStyle {
                        BackgroundColor(nil)
                    }
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 4)
                    }
                    .background(Color.secondary.opacity(0.2))
                    .frame(maxWidth: .infinity)
            }.markdownTextStyle(\.text) {
                FontSize(.em(1))
                ForegroundColor(score >= 0 ? Color.primary : Color.primary.opacity(0.4))
            }
            .markdownTextStyle(\.link) {
                ForegroundColor(Color.blue)
            }
            .padding(.trailing, 4)
    }
}

#Preview {
    MarkdownView(text: "Test", score: 0)
}
