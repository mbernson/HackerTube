//
//  MediaCCCApiClient.swift
//  CCCApi
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation
import os.log

public final class MediaCCCApiClient {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.media.ccc.de/public")!
    private let decoder = JSONDecoder()
    private let logger = Logger(subsystem: "eu.bernson.HackerTube.CCCApi", category: "MediaCCCApiClient")

    public init(urlSession: URLSession = .shared) {
        session = urlSession
        decoder.dateDecodingStrategy = .formatted(CustomISO8601DateFormatter())
    }

    // MARK: Networking

    /// Performs a GET request for the given URL, logging the request and response,
    /// and decodes the response body into the requested type.
    private func get<T: Decodable>(_ url: URL) async throws -> T {
        logger.info("GET \(url.absoluteString, privacy: .public)")
        do {
            let (data, response) = try await session.data(from: url)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            logger.info("Response code \(statusCode) \(url.absoluteString, privacy: .public) (\(data.count) bytes)")
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("GET \(url.absoluteString, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    // MARK: Conferences

    public func conferences() async throws -> [Conference] {
        let response: ConferencesResponse = try await get(baseURL.appendingPathComponent("conferences"))
        return response.conferences
    }

    public func conference(acronym: String) async throws -> Conference {
        try await get(baseURL.appendingPathComponent("conferences").appendingPathComponent(acronym))
    }

    // MARK: Talks

    public func talk(id: String) async throws -> Talk {
        try await get(baseURL.appendingPathComponent("events").appendingPathComponent(id))
    }

    public func talks() async throws -> [Talk] {
        let response: EventsResponse = try await get(baseURL.appendingPathComponent("events"))
        return response.events
    }

    public func recentTalks() async throws -> [Talk] {
        let response: EventsResponse = try await get(
            baseURL.appendingPathComponent("events").appendingPathComponent("recent"))
        return response.events
    }

    public func popularTalks(in year: Int) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("popular")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "year", value: String(year))]
        let response: EventsResponse = try await get(components.url!)
        return response.events
    }

    public func searchTalks(query: String) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("search")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let response: EventsResponse = try await get(components.url!)
        return response.events
    }

    // MARK: Recordings

    public func recordings(for talk: Talk) async throws -> [Recording] {
        let response: TalkExtended = try await get(
            baseURL.appendingPathComponent("events").appendingPathComponent(talk.guid))
        guard let recordings = response.recordings else {
            return []
        }
        return
            recordings
            // Remove formats Apple doesn't support
            .filter { !$0.mimeType.contains("opus") }
            .filter { !$0.mimeType.contains("webm") }
            .filter { !$0.mimeType.starts(with: "application") }
            // Put the HD versions first
            .sorted(by: { lhs, rhs in
                lhs.isHighQuality && !rhs.isHighQuality
            })
            // Put the audio versions last
            .sorted(by: { lhs, rhs in
                !lhs.isAudio && rhs.isAudio
            })
    }
}
