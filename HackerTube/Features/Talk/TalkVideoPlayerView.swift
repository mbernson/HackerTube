//
//  TalkVideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import MediaCCCApi

struct TalkVideoPlayerView: View {
    let talk: Talk
    let preferredRecording: Recording?
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
            if let preferredRecording {
                TalkPlayerView(
                    talk: talk,
                    recording: preferredRecording,
                    automaticallyStartsPlayback: true
                )
            } else {
                Rectangle()
                    .fill(.black)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    TalkVideoPlayerView(talk: .example, preferredRecording: .example)
}
