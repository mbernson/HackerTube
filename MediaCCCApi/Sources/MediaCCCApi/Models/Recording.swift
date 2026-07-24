//
//  Recording.swift
//  MediaCCCApi
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

struct RecordingsResponse: Decodable {
    let recordings: [Recording]
}

/// A recording is a file that belongs to a talk (event).
/// These can be video or audio recordings of the talk in different formats and languages (live-translation), subtitle tracks as srt or slides as pdf.
public struct Recording: Decodable, Identifiable, Equatable, Sendable {
    /// Approximate file size, reported by the API in megabytes.
    public let size: Measurement<UnitInformationStorage>?
    /// duration in seconds
    public let length: TimeInterval?
    public let mimeType: String
    public let language: String
    public let filename: String
    public let state: String
    public let folder: String
    /// A human-readable label for the recording (e.g. quality/format), if provided.
    public let label: String?
    public let isHighQuality: Bool
    public let width: Int?
    public let height: Int?
    public let updatedAt: Date?
    public let url: URL
    public let recordingURL: URL
    public let eventURL: URL
    public let conferenceURL: URL

    public var id: String { filename }

    public var isAudio: Bool {
        mimeType.starts(with: "audio")
    }

    public var isVideo: Bool {
        mimeType.starts(with: "video")
    }

    init(
        size: Measurement<UnitInformationStorage>?, length: TimeInterval?, mimeType: String,
        language: String, filename: String, state: String, folder: String, label: String? = nil,
        isHighQuality: Bool, width: Int?, height: Int?, updatedAt: Date?, recordingURL: URL,
        url: URL, eventURL: URL, conferenceURL: URL
    ) {
        self.size = size
        self.length = length
        self.mimeType = mimeType
        self.language = language
        self.filename = filename
        self.state = state
        self.folder = folder
        self.label = label
        self.isHighQuality = isHighQuality
        self.width = width
        self.height = height
        self.updatedAt = updatedAt
        self.url = url
        self.recordingURL = recordingURL
        self.eventURL = eventURL
        self.conferenceURL = conferenceURL
    }

    enum CodingKeys: String, CodingKey {
        case size
        case length
        case mimeType = "mime_type"
        case language
        case filename
        case state
        case folder
        case label
        case isHighQuality = "high_quality"
        case width
        case height
        case updatedAt = "updated_at"
        case url
        case recordingURL = "recording_url"
        case eventURL = "event_url"
        case conferenceURL = "conference_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let sizeMegabytes = try? container.decode(Double.self, forKey: .size) {
            size = Measurement(value: sizeMegabytes, unit: .megabytes)
        } else {
            size = nil
        }
        length = try container.decode(TimeInterval?.self, forKey: .length)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        language = try container.decode(String.self, forKey: .language)
        filename = try container.decode(String.self, forKey: .filename)
        state = try container.decode(String.self, forKey: .state)
        folder = try container.decode(String.self, forKey: .folder)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        isHighQuality = try container.decode(Bool.self, forKey: .isHighQuality)
        width = try container.decode(Int?.self, forKey: .width)
        height = try container.decode(Int?.self, forKey: .height)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        url = try container.decode(URL.self, forKey: .url)
        recordingURL = try container.decode(URL.self, forKey: .recordingURL)
        eventURL = try container.decode(URL.self, forKey: .eventURL)
        conferenceURL = try container.decode(URL.self, forKey: .conferenceURL)
    }
}
