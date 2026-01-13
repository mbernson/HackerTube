//
//  TalkViewModel.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import AVKit
import CCCApi
import Foundation

enum CopyrightState: Equatable {
    case loading
    case copyright(String)
    case unknown
}

@Observable
class TalkViewModel {
    var currentTalk: Talk?
    var recordings: [Recording] = []
    var selectedRecording: Recording?
    var copyright: CopyrightState = .loading

    private let client: MediaCCCApiClient
    private let mediaAnalyzer: MediaAnalyzer
    private let recordingChooser: RecordingChooser

    init() {
        client = .init()
        mediaAnalyzer = .init()
        recordingChooser = .init()
    }

    func loadRecordings(for talk: Talk) async throws {
        // Populate the recordings dropdown
        recordings = try await client.recordings(for: talk)
            // Remove everything that's not playable
            .filter { recordingChooser.canPlay(recording: $0) }
            // Put the HD versions first
            .sorted(by: { lhs, rhs in
                return lhs.isHighQuality && !rhs.isHighQuality
            })
            // Put the audio versions last
            .sorted(by: { lhs, rhs in
                return !lhs.isAudio && rhs.isAudio
            })

        // Pre-select the preferred recording
        selectedRecording = recordingChooser.choosePreferredRecording(
            from: recordings,
            prefersHighQuality: true, // TODO: Hook up with a preference and/or respect low data mode
            prefersAudio: false // TODO: Hook up with a preference 'prefer audio'
        )

        currentTalk = talk

        await loadCopyright(for: recordings)
    }

    private func loadCopyright(for recordings: [Recording]) async {
        for recording in recordings where copyright == .loading {
            if let copyrightString = try? await mediaAnalyzer.copyrightMetadata(for: recording) {
                copyright = .copyright(copyrightString)
            }
        }
        if copyright == .loading {
            copyright = .unknown
        }
    }
}
