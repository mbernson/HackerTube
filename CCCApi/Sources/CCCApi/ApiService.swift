//
//  ApiService.swift
//  CCCApi
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

@MainActor
@Observable
public class ApiService {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.media.ccc.de/public")!
    private let decoder = JSONDecoder()

    public static let shared = ApiService()

    public init() {
        session = URLSession(configuration: .default)
        decoder.dateDecodingStrategy = .formatted(CustomISO8601DateFormatter())
    }

    // MARK: Conferences

    public func conferences() async throws -> [Conference] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("conferences"))
        let response = try decoder.decode(ConferencesResponse.self, from: data)
        return response.conferences
    }

    public func conference(acronym: String) async throws -> Conference {
        let (data, _) = try await session.data(
            from: baseURL.appendingPathComponent("conferences").appendingPathComponent(acronym))
        return try decoder.decode(Conference.self, from: data)
    }

    // MARK: Talks

    public func talk(id: String) async throws -> Talk {
        let (data, _) = try await session.data(
            from: baseURL.appendingPathComponent("events").appendingPathComponent(id))
        let response = try decoder.decode(Talk.self, from: data)
        return response
    }

    public func talks() async throws -> [Talk] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events"))
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func recentTalks() async throws -> [Talk] {
        let (data, _) = try await session.data(
            from: baseURL.appendingPathComponent("events").appendingPathComponent("recent"))
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func popularTalks(in year: Int) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("popular")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "year", value: String(year))]
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func searchTalks(query: String) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("search")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    // MARK: Recordings

    public func recordings(for talk: Talk) async throws -> [Recording] {
        let (data, _) = try await session.data(
            from: baseURL.appendingPathComponent("events").appendingPathComponent(talk.guid))
        let response = try decoder.decode(TalkExtended.self, from: data)
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
