//
//  TalkPlayerViewModel.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import AVKit
import CCCApi
import Foundation
import os.log

@Observable
@MainActor
class TalkPlayerViewModel {
    var player = AVPlayer()

    var currentRecording: Recording?

    private(set) var isPlaying = false

    @ObservationIgnored
    private let factory = TalkMetadataFactory()

    @ObservationIgnored
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TalkPlayerViewModel")

    @ObservationIgnored
    private var timeControlObserver: NSKeyValueObservation?

    init() {
        timeControlObserver = player.observe(\.timeControlStatus, options: [.initial, .new]) {
            [weak self] player, _ in
            let playing = player.timeControlStatus == .playing
            Task { @MainActor [weak self] in
                self?.isPlaying = playing
            }
        }
    }

    func prepareForPlayback(recording: Recording, talk: Talk) async {
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

        let playerItem = AVPlayerItem(url: recording.recordingURL)
        playerItem.externalMetadata = metadata

        player.replaceCurrentItem(with: playerItem)
        self.currentRecording = recording
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
            var didResume = false
            let resume: (Bool) -> Void = { ready in
                guard !didResume else { return }
                didResume = true
                continuation.resume(returning: ready)
            }

            observation = player.observe(\.status, options: [.initial, .new]) { player, _ in
                switch player.status {
                case .readyToPlay:
                    resume(true)
                case .failed:
                    resume(false)
                default:
                    break
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
}
