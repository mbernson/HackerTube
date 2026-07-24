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
    }
}

#Preview {
    TalkVideoPlayerView(talk: .example, preferredRecording: .example)
}
