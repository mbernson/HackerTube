//
//  MediaCCCApiClient.swift
//  MediaCCCApi
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation
import os.log

public final class MediaCCCApiClient {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.media.ccc.de/public")!
    private let decoder = JSONDecoder()
    private let logger = Logger(subsystem: "eu.bernson.HackerTube.MediaCCCApi", category: "MediaCCCApiClient")

    public init(urlSession: URLSession = .shared) {
        session = urlSession
        decoder.dateDecodingStrategy = .formatted(CustomISO8601DateFormatter())
    }

    // MARK: Networking

    /// Performs a GET request for the given URL and decodes the response body,
    /// discarding the response metadata.
    private func get<T: Decodable>(_ url: URL) async throws -> T {
        try await getWithResponse(url).0
    }

    /// Performs a GET request for the given URL, logging the request and response,
    /// and decodes the response body into the requested type. Also returns the
    /// `HTTPURLResponse` so callers can read pagination headers.
    private func getWithResponse<T: Decodable>(_ url: URL) async throws -> (T, HTTPURLResponse) {
        logger.info("GET \(url.absoluteString, privacy: .public)")
        do {
            let (data, response) = try await session.data(from: url)
            let http = response as? HTTPURLResponse
            let statusCode = http?.statusCode ?? -1
            logger.info("Response code \(statusCode) \(url.absoluteString, privacy: .public) (\(data.count) bytes)")
            let decoded = try decoder.decode(T.self, from: data)
            return (decoded, http ?? HTTPURLResponse())
        } catch {
            logger.error("GET \(url.absoluteString, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    /// Performs a form-encoded POST request and decodes the response body.
    private func post<T: Decodable>(_ url: URL, form: [String: String]) async throws -> T {
        logger.info("POST \(url.absoluteString, privacy: .public)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var components = URLComponents()
        components.queryItems = form.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            logger.info("Response code \(statusCode) \(url.absoluteString, privacy: .public) (\(data.count) bytes)")
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("POST \(url.absoluteString, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    /// Builds a URL under the API base from path components and an optional query.
    /// Query entries with a `nil` value are omitted.
    private func url(path: [String], query: [String: String?] = [:]) -> URL {
        let url = path.reduce(baseURL) { $0.appendingPathComponent($1) }
        let items = query.compactMap { key, value in
            value.map { URLQueryItem(name: key, value: $0) }
        }
        guard !items.isEmpty else { return url }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = items.sorted { $0.name < $1.name }
        return components.url!
    }

    /// Parses the `api-pagination` headers (`Total`, `Per-Page`, `Link`) from a
    /// response into pagination metadata for the requested page.
    private func paginationInfo(
        from response: HTTPURLResponse, page: Int
    ) -> (perPage: Int?, total: Int?, nextPage: Int?) {
        let total = (response.value(forHTTPHeaderField: "Total")).flatMap(Int.init)
        let perPage = (response.value(forHTTPHeaderField: "Per-Page")).flatMap(Int.init)
        let hasNext = response.value(forHTTPHeaderField: "Link")?.contains("rel=\"next\"") == true
        return (perPage, total, hasNext ? page + 1 : nil)
    }

    /// Fetches a page of talks from an events list endpoint and assembles a ``Page``.
    private func talkPage(url: URL, page: Int) async throws -> Page<Talk> {
        let (body, response): (EventsResponse, HTTPURLResponse) = try await getWithResponse(url)
        let info = paginationInfo(from: response, page: page)
        return Page(
            items: body.events, currentPage: page, perPage: info.perPage,
            totalCount: info.total, nextPage: info.nextPage)
    }

    // MARK: Conferences

    /// Lists conferences. By default only conferences with at least one recorded
    /// event are returned.
    /// - Parameters:
    ///   - includeEmpty: Also include conferences without any associated events.
    ///   - urlContains: Filter to conferences whose website (`link`) contains this substring.
    ///   - currentlyStreaming: Restrict to conferences that are currently live-streaming.
    public func conferences(
        includeEmpty: Bool = false, urlContains: String? = nil, currentlyStreaming: Bool = false
    ) async throws -> [Conference] {
        let url = url(
            path: ["conferences"],
            query: [
                "include_empty": includeEmpty ? "true" : nil,
                "url_contains": urlContains,
                "currently_streaming": currentlyStreaming ? "true" : nil,
            ])
        let response: ConferencesResponse = try await get(url)
        return response.conferences
    }

    /// Lists the conferences that have the most recent events.
    /// - Parameter limit: Number of conferences to return (server-clamped to 1–30).
    public func recentConferences(limit: Int = 5) async throws -> [Conference] {
        let url = url(path: ["conferences", "recent"], query: ["limit": String(limit)])
        let response: ConferencesResponse = try await get(url)
        return response.conferences
    }

    /// Fetches a single conference by numeric id or acronym.
    public func conference(acronym: String) async throws -> Conference {
        try await get(url(path: ["conferences", acronym]))
    }

    // MARK: Talks

    public func talk(id: String) async throws -> Talk {
        try await get(url(path: ["events", id]))
    }

    // Note: the list endpoints below are backed by the `api-pagination` helper with a
    // fixed server-side page size (the controller passes an explicit `per_page:`, which
    // overrides the query param), so only `page` is adjustable. Search is the exception
    // — its controller reads `per_page` from the query directly.

    /// Lists all events, paginated (fixed server page size of 50).
    public func talks(page: Int = 1) async throws -> Page<Talk> {
        let url = url(path: ["events"], query: ["page": String(page)])
        return try await talkPage(url: url, page: page)
    }

    /// Lists recently released events, paginated (fixed server page size of 100).
    public func recentTalks(page: Int = 1) async throws -> Page<Talk> {
        let url = url(path: ["events", "recent"], query: ["page": String(page)])
        return try await talkPage(url: url, page: page)
    }

    /// Lists promoted (editorially featured) events. Not paginated; up to 100 events.
    public func promotedTalks() async throws -> [Talk] {
        let response: EventsResponse = try await get(url(path: ["events", "promoted"]))
        return response.events
    }

    /// Lists the most-viewed events for a year, paginated (fixed server page size of 50).
    public func popularTalks(in year: Int, page: Int = 1) async throws -> Page<Talk> {
        let url = url(path: ["events", "popular"], query: ["year": String(year), "page": String(page)])
        return try await talkPage(url: url, page: page)
    }

    /// Lists the least-viewed events for a year, paginated (fixed server page size of 50).
    public func unpopularTalks(in year: Int, page: Int = 1) async throws -> Page<Talk> {
        let url = url(path: ["events", "unpopular"], query: ["year": String(year), "page": String(page)])
        return try await talkPage(url: url, page: page)
    }

    /// Full-text event search, paginated. `perPage` defaults server-side to 25 (clamped 1–256).
    public func searchTalks(query: String, page: Int = 1, perPage: Int? = nil) async throws -> Page<Talk> {
        let url = url(
            path: ["events", "search"],
            query: ["q": query, "page": String(page), "per_page": perPage.map(String.init)])
        return try await talkPage(url: url, page: page)
    }

    // MARK: Recordings

    /// Lists all recordings, paginated (fixed server page size of 50).
    public func recordings(page: Int = 1) async throws -> Page<Recording> {
        let url = url(path: ["recordings"], query: ["page": String(page)])
        let (body, response): (RecordingsResponse, HTTPURLResponse) = try await getWithResponse(url)
        let info = paginationInfo(from: response, page: page)
        return Page(
            items: body.recordings, currentPage: page, perPage: info.perPage,
            totalCount: info.total, nextPage: info.nextPage)
    }

    /// Fetches a single recording by its numeric id.
    public func recording(id: Int) async throws -> Recording {
        try await get(url(path: ["recordings", String(id)]))
    }

    /// Fetches the recordings embedded in an event and returns the ones playable on
    /// Apple platforms, HD and video first.
    ///
    /// Recordings arrive embedded in the event `show` response, so this is a single
    /// request. The MIME filtering below overlaps with `RecordingChooser` in the app
    /// and should eventually be consolidated there.
    public func recordings(for talk: Talk) async throws -> [Recording] {
        let response: TalkExtended = try await get(url(path: ["events", talk.guid]))
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

private struct CountResponse: Decodable {
    let status: String?
}
