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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CCCApi")

    public init(urlSession: URLSession = .shared) {
        session = urlSession
        decoder.dateDecodingStrategy = .formatted(CustomISO8601DateFormatter())
    }

    // MARK: Conferences

    public func conferences() async throws -> [Conference] {
        let url = baseURL.appendingPathComponent("conferences")
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(ConferencesResponse.self, from: data)
        return response.conferences
    }

    public func conference(acronym: String) async throws -> Conference {
        let url = baseURL.appendingPathComponent("conferences").appendingPathComponent(acronym)
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        return try decoder.decode(Conference.self, from: data)
    }

    // MARK: Talks

    public func talk(id: String) async throws -> Talk {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent(id)
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(Talk.self, from: data)
        return response
    }

    public func talks() async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events")
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func recentTalks() async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("recent")
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func popularTalks(in year: Int) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("popular")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "year", value: String(year))]
        logger.debug("GET \(components.url!)")
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func searchTalks(query: String) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("search")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        logger.debug("GET \(components.url!)")
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    // MARK: Recordings

    public func recordings(for talk: Talk) async throws -> [Recording] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent(talk.guid)
        logger.debug("GET \(url)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(TalkExtended.self, from: data)
        return response.recordings ?? []
    }
}
