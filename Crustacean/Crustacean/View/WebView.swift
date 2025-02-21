//
//  WebView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 21/02/2025.
//

import OSLog
import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var showLoginView: Bool

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WebView")

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)

        webView.navigationDelegate = context.coordinator

        webView.load(request)

        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
            if let redirectedUrl = navigationAction.request.url {
                parent.logger.info("Redirect URL \(redirectedUrl)")

                // Redirected back to the homepage.
                if redirectedUrl == URL(string: "https://lobste.rs/")! {
                    decisionHandler(.cancel)

                    // Copy cookies to HTTPCookieStorage for URLSession.
                    WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                        for cookie in cookies {
                            HTTPCookieStorage.shared.setCookie(cookie)
                        }
                    }

                    parent.showLoginView = false
                    return
                }
            }

            decisionHandler(.allow)
        }

        func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            parent.logger.info("Webview started loading.")
        }

        func webView(_: WKWebView, didFinish _: WKNavigation!) {
            parent.logger.info("Webview finished loading.")
        }

        func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
            parent.logger.info("Webview failed with error: \(error.localizedDescription)")
        }
    }
}
