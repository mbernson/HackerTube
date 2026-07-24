//
//  TalkPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

struct TalkPlayerView: View {
    let talk: Talk
    let recording: Recording
    let automaticallyStartsPlayback: Bool

    @State private var isLoading = false
    @State private var viewModel = TalkPlayerViewModel()

    var body: some View {
        VideoPlayerView(player: viewModel.player)
            .accessibilityIdentifier("Video")
            .task(id: recording) {
                guard recording != viewModel.currentRecording else { return }

                isLoading = true
                await viewModel.prepareForPlayback(recording: recording, talk: talk)
                if automaticallyStartsPlayback {
                    viewModel.play()
                } else {
                    await viewModel.preroll()
                }
                isLoading = false
            }
            .onDisappear {
                viewModel.pause()
            }
            #if os(iOS)
                .overlay {
                    if isLoading {
                        VideoProgressIndicator()
                    }
                }
            #endif
    }
}

#if os(iOS)
    private struct VideoProgressIndicator: View {
        var body: some View {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .padding(10)
                .background(.regularMaterial)
                .clipShape(Circle())
        }
    }
#endif

#Preview {
    TalkPlayerView(talk: .example, recording: .example, automaticallyStartsPlayback: false)
}
