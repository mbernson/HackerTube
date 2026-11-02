//
//  DeepLinkedTalkView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import MediaCCCApi
import SwiftUI

/// Shows a talk that is only known by its identifier, such as the target of a deep link.
struct DeepLinkedTalkView: View {
    let id: String
    let autoplay: Bool

    @State private var talk: Talk?
    @State private var error: Error?
    @State private var didFail = false
    @Environment(ApiService.self) private var api

    var body: some View {
        Group {
            if let talk {
                TalkView(talk: talk, autoplay: autoplay)
            } else if didFail {
                ContentUnavailableView("Talk not available", systemImage: "exclamationmark.triangle")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: id) {
            guard talk?.id != id else { return }
            do {
                talk = try await api.talk(id: id)
            } catch is CancellationError {
            } catch {
                self.error = error
                didFail = true
            }
        }
        .alert("Failed to load data from the media.ccc.de API", error: $error)
    }
}
