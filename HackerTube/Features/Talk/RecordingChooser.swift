//
//  RecordingChooser.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 13/01/2026.
//

import AVFoundation
import CCCApi
import Foundation

struct RecordingChooser {
    let preferredLanguages: [Locale]

    init(preferredLanguages: [Locale] = {
        if #available(iOS 26, tvOS 26, macOS 26, *) {
            return Locale.preferredLocales
        } else {
            return Locale.preferredLanguages.map(Locale.init(identifier:))
        }
    }()) {
        self.preferredLanguages = preferredLanguages
    }

    /// Checks whether the app on the current OS can play back the given recording.
    func canPlay(recording: Recording) -> Bool {
        let mimeType = recording.mimeType

        // Ignore any files that are attachments (talk slides) etc.
        if mimeType.starts(with: "application") {
            return false
        }

        // Subtitle file, this cannot be played back
        if mimeType.starts(with: "text") {
            return false
        }

        return AVURLAsset.isPlayableExtendedMIMEType(mimeType)
    }

    /// Selects the best recording to be played, based on the parameters and user preferences.
    func choosePreferredRecording(
        from recordings: [Recording],
        prefersHighQuality: Bool,
        prefersAudio: Bool
    ) -> Recording? {
        return recordings
            // Remove everything that's not playable
            .filter(canPlay)
            // Put the audio versions first, if desired
            .sorted(by: { lhs, rhs in
                if prefersAudio {
                    return lhs.isAudio && !rhs.isAudio
                } else {
                    return !lhs.isAudio && rhs.isAudio
                }
            })
            // Sort by language preference
            .sorted { lhs, rhs in
                let l = languageScore(for: lhs)
                let r = languageScore(for: rhs)
                if l.0 != r.0 { return l.0 > r.0 }
                return l.1 < r.1
            }
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

    private func languageScore(for recording: Recording) -> (Int, Int) {
        let preferredCodes = preferredLanguages.compactMap { $0.language.languageCode }
        // Normalize ISO 639-2 codes (e.g. "eng") to BCP-47 (e.g. "en") via Locale
        let recordingCodes = recording.language
            .split(separator: "-")
            .compactMap { Locale(identifier: String($0)).language.languageCode }
        let matchCount = recordingCodes.filter { preferredCodes.contains($0) }.count
        let firstMatchIndex = preferredCodes.firstIndex { recordingCodes.contains($0) } ?? Int.max
        return (matchCount, firstMatchIndex)
    }
}
