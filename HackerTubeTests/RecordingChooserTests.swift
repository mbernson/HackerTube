//
//  RecordingChooserTests.swift
//  HackerTubeTests
//

import Foundation
import Testing
@testable import HackerTube
@testable import CCCApi

@Suite("RecordingChooser")
struct RecordingChooserTests {

    @Suite("canPlay")
    struct CanPlay {
        let chooser = RecordingChooser()

        @Test("Rejects unplayable MIME types", arguments: [
            "text/vtt",
            "application/pdf",
        ])
        func rejectsUnplayable(_ mimeType: String) {
            #expect(chooser.canPlay(recording: .make(mimeType: mimeType)) == false)
        }

        @Test("Accepts playable MIME types", arguments: [
            "video/mp4",
            "video/mp4;codecs=av01",
            "audio/mpeg",
        ])
        func acceptsPlayable(_ mimeType: String) {
            #expect(chooser.canPlay(recording: .make(mimeType: mimeType)))
        }
    }

    @Suite("choosePreferredRecording")
    struct ChoosePreferred {
        let chooser = RecordingChooser()

        @Test func returnsNilForEmptyList() {
            #expect(
                chooser.choosePreferredRecording(from: [], prefersHighQuality: true, prefersAudio: false) == nil
            )
        }

        @Test func returnsNilWhenAllUnplayable() {
            let recordings = [
                Recording.make(mimeType: "video/webm"),
                Recording.make(mimeType: "text/vtt"),
                Recording.make(mimeType: "application/pdf"),
            ]
            #expect(
                chooser.choosePreferredRecording(from: recordings, prefersHighQuality: true, prefersAudio: false) == nil
            )
        }

        // [Recording].example contains: audio/mpeg (LQ), video/mp4 (SD/LQ), video/mp4 (HD/HQ)

        @Test func prefersHDVideoByDefault() {
            let result = chooser.choosePreferredRecording(
                from: .example,
                prefersHighQuality: true,
                prefersAudio: false
            )
            #expect(result?.isHighQuality == true)
            #expect(result?.isVideo == true)
        }

        @Test func prefersSDWhenLowQualityRequested() {
            let result = chooser.choosePreferredRecording(
                from: .example,
                prefersHighQuality: false,
                prefersAudio: false
            )
            #expect(result?.isHighQuality == false)
            #expect(result?.isVideo == true)
        }

        @Test func prefersAudioOverVideoWhenRequested() {
            // Both same quality — audio preference is the deciding factor
            let recordings = [
                Recording.make(mimeType: "video/mp4", isHighQuality: false),
                Recording.make(mimeType: "audio/mpeg", isHighQuality: false),
            ]
            let result = chooser.choosePreferredRecording(
                from: recordings,
                prefersHighQuality: false,
                prefersAudio: true
            )
            #expect(result?.isAudio == true)
        }

        @Test func prefersHDAudioWhenBothPreferred() {
            let recordings = [
                Recording.make(mimeType: "video/mp4", isHighQuality: true),
                Recording.make(mimeType: "video/mp4", isHighQuality: false),
                Recording.make(mimeType: "audio/mpeg", isHighQuality: false),
                Recording.make(mimeType: "audio/mpeg", isHighQuality: true),
            ]
            let result = chooser.choosePreferredRecording(
                from: recordings,
                prefersHighQuality: true,
                prefersAudio: true
            )
            #expect(result?.isAudio == true)
            #expect(result?.isHighQuality == true)
        }

        @Test func filtersWebmEvenWhenFirstInList() {
            let recordings = [
                Recording.make(mimeType: "video/webm", isHighQuality: true),
                Recording.make(mimeType: "video/webm;codecs=av01", isHighQuality: true),
                Recording.make(mimeType: "video/mp4", isHighQuality: false),
            ]
            let result = chooser.choosePreferredRecording(
                from: recordings,
                prefersHighQuality: true,
                prefersAudio: false
            )
            #expect(result?.mimeType == "video/mp4")
        }

        @Suite("realWorldData")
        struct RealWorldData {
            private func loadRecordings(
                fromJSON filename: String,
                file: StaticString = #filePath
            ) throws -> [Recording] {
                let url = URL(filePath: "\(file)")
                    .deletingLastPathComponent()
                    .appending(path: "TestData/\(filename)")
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(CustomISO8601DateFormatter())
                struct TalkJSON: Decodable { let recordings: [Recording] }
                return try decoder.decode(TalkJSON.self, from: data).recordings
            }

            @Test func englishSpeakerGetsEnglishRecordingFromDoctorowTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "en")])
                let recordings = try loadRecordings(fromJSON: "event-39c3-a-post-american-enshittification-resistant-internet.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                #expect(result?.language.contains("eng") == true)
                #expect(result?.isHighQuality == true)
            }

            @Test func germanSpeakerGetsGermanRecordingFromDeutschlandticketsTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "de")])
                let recordings = try loadRecordings(fromJSON: "event-39c3-all-my-deutschlandtickets-gone-fraud-at-an-industrial-scale.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                #expect(result?.language.contains("deu") == true)
                #expect(result?.isHighQuality == true)
            }

            @Test func germanEnglishSpeakerPrefersMultilingualRecordingFromDeutschlandticketsTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [
                    Locale(identifier: "de"), Locale(identifier: "en"),
                ])
                let recordings = try loadRecordings(fromJSON: "event-39c3-all-my-deutschlandtickets-gone-fraud-at-an-industrial-scale.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                // eng-deu-fra has 2 matching languages (de + en), beating deu-only (1) or eng-only (1)
                #expect(result?.language == "eng-deu-fra")
                #expect(result?.isHighQuality == true)
            }

            @Test func germanSpeakerGetsGermanRecordingFromFactorioTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "de")])
                let recordings = try loadRecordings(fromJSON: "event-39c3-cpu-entwicklung-in-factorio-vom-d-flip-flop-bis-zum-eigenen-betriebssystem.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                #expect(result?.language.contains("deu") == true)
                #expect(result?.isHighQuality == true)
            }

            @Test func englishSpeakerGetsEnglishRecordingFromFactorioTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "en")])
                let recordings = try loadRecordings(fromJSON: "event-39c3-cpu-entwicklung-in-factorio-vom-d-flip-flop-bis-zum-eigenen-betriebssystem.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                #expect(result?.language.contains("eng") == true)
                #expect(result?.isHighQuality == true)
            }

            @Test func germanEnglishSpeakerPrefersBilingualRecordingFromFactorioTalk() throws {
                let chooser = RecordingChooser(preferredLanguages: [
                    Locale(identifier: "de"), Locale(identifier: "en"),
                ])
                let recordings = try loadRecordings(fromJSON: "event-39c3-cpu-entwicklung-in-factorio-vom-d-flip-flop-bis-zum-eigenen-betriebssystem.json")
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                // deu-eng has 2 matching languages (de + en), beating deu-only (1) or eng-only (1)
                #expect(result?.language == "deu-eng")
                #expect(result?.isHighQuality == true)
            }
        }

        @Suite("languagePreference")
        struct LanguagePreference {
            @Test func prefersRecordingInPreferredLanguage() {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "en")])
                let recordings = [
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "fra"),
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "eng"),
                ]
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: false, prefersAudio: false
                )
                #expect(result?.language == "eng")
            }

            @Test func prefersMixedTrackContainingPreferredLanguage() {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "en")])
                let recordings = [
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "fra"),
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "deu-eng"),
                ]
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: false, prefersAudio: false
                )
                #expect(result?.language == "deu-eng")
            }

            @Test func prefersRecordingWithMoreMatchingLanguages() {
                let chooser = RecordingChooser(preferredLanguages: [
                    Locale(identifier: "de"), Locale(identifier: "en"),
                ])
                let recordings = [
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "eng"),
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "deu-eng"),
                ]
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: false, prefersAudio: false
                )
                #expect(result?.language == "deu-eng")
            }

            @Test func fallsBackToQualityWhenNoLanguageMatch() {
                let chooser = RecordingChooser(preferredLanguages: [Locale(identifier: "en")])
                let recordings = [
                    Recording.make(mimeType: "video/mp4", isHighQuality: false, language: "fra"),
                    Recording.make(mimeType: "video/mp4", isHighQuality: true, language: "fra"),
                ]
                let result = chooser.choosePreferredRecording(
                    from: recordings, prefersHighQuality: true, prefersAudio: false
                )
                #expect(result?.isHighQuality == true)
            }
        }
    }
}

// MARK: - Test Helpers

private extension Recording {
    static func make(
        mimeType: String,
        isHighQuality: Bool = false,
        language: String = "eng",
        filename: String = UUID().uuidString
    ) -> Recording {
        Recording(
            size: nil,
            length: nil,
            mimeType: mimeType,
            language: language,
            filename: filename,
            state: "new",
            folder: "",
            isHighQuality: isHighQuality,
            width: nil,
            height: nil,
            updatedAt: Date(),
            recordingURL: URL(string: "https://example.com/r")!,
            url: URL(string: "https://example.com/")!,
            eventURL: URL(string: "https://example.com/e")!,
            conferenceURL: URL(string: "https://example.com/c")!
        )
    }
}
