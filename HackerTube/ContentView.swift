//
//  ContentView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI

struct ContentView: View {
    @State private var talk: TalkToPlay?
    @State var error: Error?
    @Environment(ApiService.self) var api

    var body: some View {
        TabView {
            Tab("Recent", systemImage: "clock") {
                BrowseView(query: .recent)
            }

            Tab("Popular", systemImage: "popcorn") {
                BrowseView(query: .popular)
            }

            Tab("Conferences", systemImage: "star") {
                ConferencesView()
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .alert("Failed to load data from the media.ccc.de API", error: $error)
        .fullScreenCover(item: $talk) { talk in
            NavigationStack {
                TalkView(talk: talk.talk, selectedRecording: talk.recordingToPlay)
            }
        }
        .onOpenURL { url in
            let factory = URLParser()
            guard let route = factory.parseURL(url) else { return }
            Task {
                await openRoute(route: route)
            }
        }
    }

    func openRoute(route: URLRoute) async {
        do {
            switch route {
            case .openTalk(let id):
                let talk = try await api.talk(id: id)
                self.talk = TalkToPlay(talk: talk, recordingToPlay: nil)
            case .playTalk(let id):
                let talk = try await api.talk(id: id)
                let recordings = try await api.recordings(for: talk)
                let recording =
                    recordings.first(where: { $0.isHighQuality })
                    ?? recordings.first(where: { $0.isVideo })
                self.talk = TalkToPlay(talk: talk, recordingToPlay: recording)
            }
        } catch {
            self.error = error
        }
    }
}

private struct TalkToPlay: Identifiable {
    let id: Int = 1
    let talk: Talk
    let recordingToPlay: Recording?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
