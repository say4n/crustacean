//
//  Tab.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

let tabs: [Tab] = [
    Tab(tabName: "Hottest", tabIcon: "flame", endpoint: "/hottest.json"),
    Tab(tabName: "Active", tabIcon: "popcorn", endpoint: "/active.json")
]

class Tab: Identifiable {
    var tabName: String
    var tabIcon: String
    var endpoint: String
    
    init(tabName: String, tabIcon: String, endpoint: String) {
        self.tabName = tabName
        self.tabIcon = tabIcon
        self.endpoint = endpoint
    }
}
