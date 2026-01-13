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
    var preferredRecording: Recording?
    var copyright: CopyrightState = .loading

    private let client: MediaCCCApiClient
    private let mediaAnalyzer: MediaAnalyzer

    init() {
        client = .init()
        mediaAnalyzer = .init()
    }

    func loadRecordings(for talk: Talk) async throws {
        let recordings = try await client.recordings(for: talk)
        currentTalk = talk
        self.recordings = recordings
        let hdRecording = recordings.first(where: { $0.isHighQuality && $0.isVideo })
        let sdRecording = recordings.first(where: { !$0.isHighQuality && $0.isVideo })
        let audioRecording = recordings.first(where: { $0.isAudio })
        preferredRecording = hdRecording ?? sdRecording ?? audioRecording

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
