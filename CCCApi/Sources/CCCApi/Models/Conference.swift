//
//  Conference.swift
//  CCCApi
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

struct ConferencesResponse: Decodable {
    let conferences: [Conference]
}

/// e.g. the congress or lecture series like datengarten or openchaos
public struct Conference: Decodable, Identifiable, Sendable {
    public let acronym: String
    public let slug: String
    public let title: String
    public let updatedAt: Date?
    public let eventLastReleasedAt: Date?
    public let events: [Talk]?
    public let link: URL?
    public let description: String?
    public let aspectRatio: AspectRatio?
    public let webgenLocation: String
    public let url: URL
    public let logoURL: URL
    public let imagesURL: URL?
    public let recordingsURL: URL?

    public var id: String { slug }

    init(
        acronym: String, slug: String, title: String, updatedAt: Date?,
        eventLastReleasedAt: Date? = nil, events: [Talk]? = nil, link: URL? = nil,
        description: String? = nil, aspectRatio: AspectRatio? = nil, webgenLocation: String,
        url: URL, logoURL: URL, imagesURL: URL? = nil, recordingsURL: URL? = nil
    ) {
        self.acronym = acronym
        self.slug = slug
        self.title = title
        self.updatedAt = updatedAt
        self.eventLastReleasedAt = eventLastReleasedAt
        self.events = events
        self.link = link
        self.description = description
        self.aspectRatio = aspectRatio
        self.webgenLocation = webgenLocation
        self.url = url
        self.logoURL = logoURL
        self.imagesURL = imagesURL
        self.recordingsURL = recordingsURL
    }

    enum CodingKeys: String, CodingKey {
        case acronym
        case slug
        case title
        case updatedAt = "updated_at"
        case eventLastReleasedAt = "event_last_released_at"
        case events
        case link
        case description
        case aspectRatio = "aspect_ratio"
        case webgenLocation = "webgen_location"
        case url
        case logoURL = "logo_url"
        case imagesURL = "images_url"
        case recordingsURL = "recordings_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        acronym = try container.decode(String.self, forKey: .acronym)
        slug = try container.decode(String.self, forKey: .slug)
        title = try container.decode(String.self, forKey: .title)
        updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        eventLastReleasedAt = try container.decode(Date?.self, forKey: .eventLastReleasedAt)
        events = try? container.decode([Event].self, forKey: .events)
        link = try? container.decode(URL?.self, forKey: .link)
        description = try container.decode(String?.self, forKey: .description)
        aspectRatio = try? container.decode(AspectRatio.self, forKey: .aspectRatio)
        webgenLocation = try container.decode(String.self, forKey: .webgenLocation)
        url = try container.decode(URL.self, forKey: .url)
        logoURL = try container.decode(URL.self, forKey: .logoURL)
        imagesURL = try? container.decode(URL?.self, forKey: .imagesURL)
        recordingsURL = try? container.decode(URL?.self, forKey: .recordingsURL)
    }
}

public struct AspectRatio: Decodable, Sendable {
    public let width: Double
    public let height: Double

    public var ratio: Double { width / height }

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let parts = string.components(separatedBy: ":")
            .compactMap(Double.init)
        if parts.count != 2 {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Invalid aspect ratio")
        } else {
            width = parts[0]
            height = parts[1]
        }
    }
}
