//
//  TalkVideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import MediaCCCApi

/// The inline video player at the top of a talk's detail screen.
///
/// Only the talk that is currently loaded in the shared player shows the video. Other talks show their
/// thumbnail with a play button, so that opening a talk never takes over playback by itself.
struct TalkVideoPlayerView: View {
    let talk: Talk
    let preferredRecording: Recording?
    @Environment(PlaybackController.self) private var playback
    @Environment(AppCoordinator.self) private var coordinator

    var aspectRatio: CGFloat {
        if let recording = preferredRecording, let width = recording.width, let height = recording.height {
            let size = CGSize(width: width, height: height)
            return size.width / size.height
        } else {
            return 16 / 9
        }
    }

    var body: some View {
        Group {
            if playback.currentTalk?.id == talk.id {
                TalkPlayerView(talk: talk)
            } else {
                Button {
                    if let preferredRecording {
                        coordinator.play(talk: talk, recording: preferredRecording)
                    }
                } label: {
                    TalkThumbnail(talk: talk)
                        .overlay {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 64))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black.opacity(0.5))
                        }
                }
                .buttonStyle(.plain)
                .disabled(preferredRecording == nil)
                .accessibilityLabel("Play")
            }
        }
        // Letterbox the thumbnail or video, but don't let the color extend into the safe area under the navigation bar.
        .background(.black, ignoresSafeAreaEdges: [])
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    let playback = PlaybackController()
    TalkVideoPlayerView(talk: .example, preferredRecording: .example)
        .environment(playback)
        .environment(AppCoordinator(playback: playback))
}
