//
//  ContentView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            Tab("Recent", systemImage: "clock", value: AppTab.recent) {
                BrowseView(query: .recent, path: coordinator.path(for: .recent))
            }

            Tab("Popular", systemImage: "popcorn", value: AppTab.popular) {
                BrowseView(query: .popular, path: coordinator.path(for: .popular))
            }

            Tab("Conferences", systemImage: "star", value: AppTab.conferences) {
                ConferencesView(path: coordinator.path(for: .conferences))
            }

            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                SearchView(path: coordinator.path(for: .search))
            }
        }
        #if os(tvOS)
            .fullScreenCover(isPresented: $coordinator.isPlayerPresented) {
                TalkPlayerView()
                    .ignoresSafeArea()
            }
        #endif
        .onOpenURL { url in
            if let link = DeepLink(url: url) {
                coordinator.open(link)
            }
        }
    }
}

#Preview {
    let playback = PlaybackController()
    ContentView()
        .environment(ApiService())
        .environment(playback)
        .environment(AppCoordinator(playback: playback))
}
