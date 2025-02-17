//
//  DataSourceUtils.swift
//  Crustacean
//
//  Created by Sayan Goswami on 17/02/2025.
//

import Foundation

let BASE_URL = URL(string: "https://lobste.rs")!

protocol DataSource {
    static var shared: Self { get }
    var items: [TabType: [Post]] { get }
    var state: [TabType: DataSourceState] { get }
}

enum DataSourceState {
    case loading
    case loaded
    case error
    case unknown
}
