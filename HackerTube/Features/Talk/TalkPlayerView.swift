//
//  TalkPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import MediaCCCApi
import SwiftUI

/// Shows the app-wide shared player. What it plays is controlled by the ``PlaybackController``.
struct TalkPlayerView: View {
    /// The talk this view is shown for, or `nil` when it shows whatever is playing (the tvOS full-screen player).
    var talk: Talk? = nil

    @Environment(PlaybackController.self) private var playback

    var body: some View {
        VideoPlayerView(playback: playback)
            .accessibilityIdentifier("Video")
            .onDisappear {
                // Keep playing when the video continues in Picture in Picture, or when the shared player has
                // already moved on to another talk (that is why this view is being removed).
                let showsCurrentTalk = talk == nil || playback.currentTalk?.id == talk?.id
                if showsCurrentTalk && !playback.isPictureInPictureActive {
                    playback.pause()
                }
            }
    }
}

#Preview {
    TalkPlayerView()
        .environment(PlaybackController())
}
