//
//  AppCoordinator.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import MediaCCCApi
import SwiftUI

/// Owns the app's navigation state: the selected tab, a navigation path per tab, and the presentation of the
/// full-screen player.
///
/// The coordinator never owns an `AVPlayer`; playback itself is delegated to the ``PlaybackController``.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .recent
    var paths: [AppTab: [Destination]] = [:]

    /// Whether the full-screen player is presented. Only used on tvOS and visionOS; other platforms play inline.
    var isPlayerPresented = false

    @ObservationIgnored
    let playback: PlaybackController

    init(playback: PlaybackController) {
        self.playback = playback
    }

    /// The navigation path of the currently selected tab.
    var currentPath: [Destination] {
        get { paths[selectedTab, default: []] }
        set { paths[selectedTab] = newValue }
    }

    func path(for tab: AppTab) -> Binding<[Destination]> {
        Binding(
            get: { self.paths[tab, default: []] },
            set: { self.paths[tab] = $0 }
        )
    }

    func push(_ destination: Destination) {
        currentPath.append(destination)
    }

    // MARK: Playback

    func play(talk: Talk, recording: Recording) {
        #if os(tvOS) || os(visionOS)
            // Keep a talk that is already playing in Picture in Picture there. A different talk closes the PiP
            // window (see `PlaybackController.load`) and plays full screen.
            let isAlreadyInPictureInPicture =
                playback.isPictureInPictureActive && playback.currentRecording == recording
            if !isAlreadyInPictureInPicture {
                isPlayerPresented = true
            }
        #endif
        Task {
            await playback.load(talk: talk, recording: recording, autoplay: true)
        }
    }

    /// Returns from Picture in Picture to the talk that is playing.
    func restore(talk: Talk, recording: Recording) async {
        if currentPath.last?.talkID != talk.id {
            push(.talk(talk))
        }
        #if os(tvOS) || os(visionOS)
            isPlayerPresented = true
        #endif
    }

    // MARK: Deep links

    /// Shows the target of a deep link on top of the current tab, whatever state the app is in.
    func open(_ link: DeepLink) {
        // A presented player would cover the destination.
        isPlayerPresented = false

        switch link {
        case .talk(let id, let action):
            let autoplay = action == .play
            if currentPath.last?.talkID == id {
                // The talk is already on screen. Only start playback if that was requested.
                if autoplay, let recording = playback.currentRecording, let talk = playback.currentTalk,
                    talk.id == id
                {
                    play(talk: talk, recording: recording)
                } else if autoplay {
                    // Replace the top destination so its view loads the talk and starts playback.
                    currentPath.removeLast()
                    push(.deepLinkedTalk(id: id, autoplay: true))
                }
            } else {
                push(.deepLinkedTalk(id: id, autoplay: autoplay))
            }
        }
    }
}
