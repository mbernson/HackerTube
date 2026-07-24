//
//  VideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import AVKit
import SwiftUI
import os.log

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.delegate = context.coordinator
        playerViewController.modalPresentationStyle = .fullScreen

        playerViewController.allowsPictureInPicturePlayback = true
        #if os(tvOS)
            playerViewController.appliesPreferredDisplayCriteriaAutomatically = true
            playerViewController.transportBarIncludesTitleView = true
        #else
            playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        #endif

        // The playback speeds don't appear on tvOS unless this is explicitly set.
        playerViewController.speeds = AVPlaybackSpeed.systemDefaultSpeeds

        // Persist the user's chosen playback speed as they change it.
        context.coordinator.observeSelectedSpeed(of: playerViewController)

        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        playerViewController.player = player
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator()
    }

    static func dismantleUIViewController(
        _ playerViewController: AVPlayerViewController, coordinator: VideoPlayerCoordinator
    ) {
        playerViewController.player?.cancelPendingPrerolls()
        playerViewController.player?.pause()
    }
}

class VideoPlayerCoordinator: NSObject, AVPlayerViewControllerDelegate {
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayerCoordinator")

    private var selectedSpeedObserver: NSKeyValueObservation?

    func observeSelectedSpeed(of playerViewController: AVPlayerViewController) {
        selectedSpeedObserver = playerViewController.observe(\.selectedSpeed, options: [.new]) {
            _, change in
            if let selectedSpeed = change.newValue.flatMap({ $0 }) {
                UserDefaults.standard.set(selectedSpeed.rate, forKey: UserDefaultsKey.playbackRate.rawValue)
            }
        }
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        logger.error("Failed to start picture in picture: \(error)")
    }
}
