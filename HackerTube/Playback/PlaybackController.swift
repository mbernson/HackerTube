//
//  PlaybackController.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import AVKit
import MediaCCCApi
import Foundation
import os.log

/// Controls video playback app-wide.
///
/// There is only ever one `AVPlayer` at a time, so starting a new talk replaces whatever was playing before,
/// including a talk that is playing in Picture in Picture.
@Observable
@MainActor
final class PlaybackController {
    let player = AVPlayer()

    private(set) var currentTalk: Talk?
    private(set) var currentRecording: Recording?

    private(set) var isPlaying = false {
        didSet {
            // Keep the display awake while playback is in progress, regardless of which view is on screen.
            UIApplication.shared.isIdleTimerDisabled = isPlaying
        }
    }

    private(set) var isPictureInPictureActive = false

    /// The delegate shared by every `AVPlayerViewController` that shows ``player``.
    @ObservationIgnored
    let playerViewControllerDelegate = PlayerViewControllerDelegate()

    /// The player view controller that is currently shown in Picture in Picture, if any.
    @ObservationIgnored
    private weak var pictureInPictureViewController: AVPlayerViewController?

    /// Called when the user asks to return from Picture in Picture to the full player UI.
    @ObservationIgnored
    var onRestoreUserInterface: (@MainActor (Talk, Recording) async -> Void)?

    @ObservationIgnored
    private let factory = TalkMetadataFactory()

    @ObservationIgnored
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PlaybackController")

    @ObservationIgnored
    private var timeControlObserver: NSKeyValueObservation?

    init() {
        playerViewControllerDelegate.playback = self
        timeControlObserver = player.observe(\.timeControlStatus, options: [.initial, .new]) {
            [weak self] player, _ in
            let playing = player.timeControlStatus == .playing
            Task { @MainActor [weak self] in
                self?.isPlaying = playing
            }
        }
    }

    /// Loads a recording into the shared player, replacing the current item.
    ///
    /// Does nothing if the recording is already loaded, apart from starting playback when requested.
    func load(talk: Talk, recording: Recording, autoplay: Bool) async {
        if recording != currentRecording {
            // A different talk replaces the one in Picture in Picture. Close the PiP window, so the new talk only
            // plays in the view that started it instead of in both places at once.
            stopPictureInPicture()
            await prepareForPlayback(recording: recording, talk: talk)
            if !autoplay {
                await preroll()
            }
        }
        if autoplay {
            play()
        }
    }

    func prepareForPlayback(recording: Recording, talk: Talk) async {
        // Claim the slot before suspending, so a concurrent load for the same recording is skipped.
        currentTalk = talk
        currentRecording = recording

        player.defaultRate = UserDefaults.standard.float(forKey: UserDefaultsKey.playbackRate.rawValue)

        var metadata = factory.createMetadataItems(for: recording, talk: talk)

        // Fetch the poster artwork up front so the complete metadata set,
        // including artwork, is attached in a single assignment before the
        // item is enqueued for playback.
        if let imageURL = talk.posterURL ?? talk.thumbURL,
            let posterImageData = try? await factory.fetchImageData(forURL: imageURL),
            let posterImageMetadata = factory.createArtworkMetadataItem(imageData: posterImageData)
        {
            metadata.append(posterImageMetadata)
        }

        // Another talk may have been loaded while the artwork was being fetched.
        guard currentRecording == recording else { return }

        let playerItem = AVPlayerItem(url: recording.recordingURL)
        playerItem.externalMetadata = metadata

        player.replaceCurrentItem(with: playerItem)
        logger.info(
            "Preparing playback of recording: \(recording.recordingURL.absoluteString, privacy: .public)"
        )
    }

    func preroll() async {
        // Wait for the player to become ready before prerolling.
        let ready = await waitUntilReadyToPlay()
        guard ready else {
            logger.warning("Player failed to become ready for preroll")
            return
        }
        if await player.preroll(atRate: 1.0) {
            logger.debug("Preroll success")
        } else {
            logger.warning("Preroll failed")
        }
    }

    private func waitUntilReadyToPlay() async -> Bool {
        var observation: NSKeyValueObservation?
        defer { observation?.invalidate() }

        return await withCheckedContinuation { continuation in
            observation = player.observe(\.status, options: [.initial, .new]) { player, _ in
                if player.status == .readyToPlay {
                    continuation.resume(returning: true)
                } else if player.status == .failed {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    // MARK: Picture in Picture

    func pictureInPictureWillStart(in playerViewController: AVPlayerViewController) {
        pictureInPictureViewController = playerViewController
        isPictureInPictureActive = true
    }

    func pictureInPictureDidStop(in playerViewController: AVPlayerViewController) {
        if pictureInPictureViewController === playerViewController {
            pictureInPictureViewController = nil
        }
        isPictureInPictureActive = pictureInPictureViewController != nil
    }

    /// Closes the Picture in Picture window, if there is one.
    ///
    /// `AVPlayerViewController` has no API to stop Picture in Picture, so this detaches the shared player from the
    /// view controller that is in Picture in Picture, which makes the system close its window.
    func stopPictureInPicture() {
        guard let playerViewController = pictureInPictureViewController else { return }
        logger.info("Stopping picture in picture to play a different talk")
        playerViewController.player = nil
        pictureInPictureViewController = nil
        isPictureInPictureActive = false
    }

    func restoreUserInterface() async {
        guard let currentTalk, let currentRecording else { return }
        await onRestoreUserInterface?(currentTalk, currentRecording)
    }
}
