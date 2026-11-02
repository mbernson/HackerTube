//
//  VideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import AVKit
import SwiftUI

struct VideoPlayerView: UIViewControllerRepresentable {
    let playback: PlaybackController

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        // The delegate is owned by the playback controller, so it outlives this view while in Picture in Picture.
        playerViewController.delegate = playback.playerViewControllerDelegate
        playerViewController.modalPresentationStyle = .fullScreen

        #if os(tvOS)
            // Picture in Picture is deliberately disabled on tvOS: talks are mostly slides, which are unreadable in
            // a small window on a TV, and watching on a TV is a single-task activity.
            playerViewController.allowsPictureInPicturePlayback = false
            playerViewController.appliesPreferredDisplayCriteriaAutomatically = true
            playerViewController.transportBarIncludesTitleView = true
        #elseif os(visionOS)
            // visionOS plays full screen, like tvOS, and the coordinator's presentation logic assumes no
            // Picture in Picture there.
            playerViewController.allowsPictureInPicturePlayback = false
        #else
            playerViewController.allowsPictureInPicturePlayback = true
            playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        #endif

        // The playback speeds don't appear on tvOS unless this is explicitly set.
        playerViewController.speeds = AVPlaybackSpeed.systemDefaultSpeeds

        // Persist the user's chosen playback speed as they change it.
        context.coordinator.observeSelectedSpeed(of: playerViewController)

        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        if playerViewController.player !== playback.player {
            playerViewController.player = playback.player
        }
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator(playback: playback)
    }
}

@MainActor
class VideoPlayerCoordinator: NSObject {
    let playback: PlaybackController

    private var selectedSpeedObserver: NSKeyValueObservation?

    init(playback: PlaybackController) {
        self.playback = playback
    }

    func observeSelectedSpeed(of playerViewController: AVPlayerViewController) {
        selectedSpeedObserver = playerViewController.observe(\.selectedSpeed, options: [.new]) {
            _, change in
            if let selectedSpeed = change.newValue.flatMap({ $0 }) {
                UserDefaults.standard.set(selectedSpeed.rate, forKey: UserDefaultsKey.playbackRate.rawValue)
            }
        }
    }
}
