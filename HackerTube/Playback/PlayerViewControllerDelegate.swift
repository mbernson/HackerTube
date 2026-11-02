//
//  PlayerViewControllerDelegate.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import AVKit
import os.log

/// The delegate of every `AVPlayerViewController` in the app.
///
/// It is owned by the ``PlaybackController`` instead of by an individual view, so Picture in Picture callbacks keep
/// arriving after the view that started Picture in Picture has been removed from the screen.
@MainActor
final class PlayerViewControllerDelegate: NSObject, AVPlayerViewControllerDelegate {
    weak var playback: PlaybackController?

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: "PlayerViewControllerDelegate")

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        logger.error("Failed to start picture in picture: \(error)")
    }

    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        playback?.pictureInPictureWillStart(in: playerViewController)
    }

    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        playback?.pictureInPictureDidStop(in: playerViewController)
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        guard let playback else {
            completionHandler(false)
            return
        }
        Task {
            await playback.restoreUserInterface()
            completionHandler(true)
        }
    }
}
