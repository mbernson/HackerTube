//
//  RecordingChooser.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 13/01/2026.
//

import CCCApi
import Foundation

struct RecordingChooser {
    func canPlay(recording: Recording) -> Bool {
        // AVPlayer cannot play Webm video
        if recording.mimeType.contains("webm") {
            return false
        }
        // Ignore any files that are attachments (talk slides) etc.
        if recording.mimeType.starts(with: "application") {
            return false
        }
        // Subtitle file, this cannot be played back
        if recording.mimeType.starts(with: "text") {
            return false
        }

        return true
    }

    func choosePreferredRecording(
        from recordings: [Recording],
        prefersHighQuality: Bool,
        prefersAudio: Bool
    ) -> Recording? {
        // TODO: Sort according to the user's preferred language(s)
        return recordings
            // Remove everything that's not playable
            .filter { canPlay(recording: $0) }
            // Put the audio versions first, if desired
            .sorted(by: { lhs, rhs in
                if prefersAudio {
                    return lhs.isAudio && !rhs.isAudio
                } else {
                    return !lhs.isAudio && rhs.isAudio
                }
            })
            // Put the HD versions first, if desired
            .sorted(by: { lhs, rhs in
                if prefersHighQuality {
                    return lhs.isHighQuality && !rhs.isHighQuality
                } else {
                    return !lhs.isHighQuality && rhs.isHighQuality
                }
            })
            .first
    }
}
