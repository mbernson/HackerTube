//
//  TalkVideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import CCCApi

struct TalkVideoPlayerView: View {
    let talk: Talk
    let preferredRecording: Recording?

    var body: some View {
        #if os(tvOS) || os(visionOS)
            TVPlayerView(talk: talk, recording: preferredRecording)
        #else
            Group {
                if let preferredRecording {
                    TalkPlayerView(
                        talk: talk, recording: preferredRecording,
                        automaticallyStartsPlayback: true)
                } else {
                    Rectangle()
                        .fill(.black)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(16 / 9, contentMode: .fit)
        #endif
    }
}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
private struct TVPlayerView: View {
    let talk: Talk
    let recording: Recording?
    @State private var selectedRecording: Recording?

    var body: some View {
        Button {
            selectedRecording = recording
        } label: {
            TalkThumbnail(talk: talk)
                .overlay {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 20)
                }
        }
        .disabled(recording == nil)
        .fullScreenCover(item: $selectedRecording) { recording in
            TalkPlayerView(talk: talk, recording: recording, automaticallyStartsPlayback: true)
        }
    }
}

#Preview {
    TalkVideoPlayerView(talk: .example, preferredRecording: .example)
}
