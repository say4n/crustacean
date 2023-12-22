//
//  CrustaceanTabView.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import SwiftUI

struct CrustaceanTabView: View {
    let tab: Tab
    @State private var tabEndpoint: String = ""
    @State private var dataState: DataFetchState = .Loading
    
    @State private var posts: [Post] = []
    
    var body: some View {
        NavigationView {
            Group {
                switch dataState {
                case .Loading:
                    VStack {
                        ProgressView()
                        Text("Fetching stories")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                case .Failure:
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                        Text("Failed to load stories")
                    }
                case .Success:
                    List {
                        ForEach(posts) { post in
                            PostListItemView(post: post)
                        }
                    }.listStyle(.plain)
                }
            }
            .navigationTitle(tab.tabName)
        }.onAppear {
            tabEndpoint = baseUrl + tab.endpoint
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let url = URL(string: tabEndpoint) {
                    if let data = try? Data(contentsOf: url) {
                        let postParser = JSONParser()
                        postParser.parse(of: [Post].self, from: data) { result in
                            switch result {
                            case .failure(_):
                                dataState = .Failure
                            case let .success(parsedPosts):
                                posts = parsedPosts
                                dataState = .Success
                            }
                        }
                        return
                    }
                }
                
                dataState = .Failure
            }
        }
    }
}

#Preview {
    CrustaceanTabView(
        tab: Tab(
            tabName: "Crustacean",
            tabIcon: "ladybug",
            endpoint: "this-endpoint-does-not-exist"
        )
    )
}
