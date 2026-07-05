//
//  ApiService.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 13/01/2026.
//

import CCCApi
import Foundation

@Observable
class ApiService {
    private let client: MediaCCCApiClient

    init() {
        client = .init()
    }

    // MARK: Conferences

    func conferences() async throws -> [Conference] {
        try await client.conferences()
    }

    func recentConferences(limit: Int = 5) async throws -> [Conference] {
        try await client.recentConferences(limit: limit)
    }

    func conference(acronym: String) async throws -> Conference {
        try await client.conference(acronym: acronym)
    }

    // MARK: Talks

    func talk(id: String) async throws -> Talk {
        try await client.talk(id: id)
    }

    // Array-returning convenience wrappers (page 1) used by the current views.
    // Prefer the paginated variants below for infinite scroll.

    func recentTalks() async throws -> [Talk] {
        try await client.recentTalks().items
    }

    func popularTalks(in year: Int) async throws -> [Talk] {
        try await client.popularTalks(in: year).items
    }

    func searchTalks(query: String) async throws -> [Talk] {
        try await client.searchTalks(query: query).items
    }

    func promotedTalks() async throws -> [Talk] {
        try await client.promotedTalks()
    }

    // Paginated variants for future infinite-scroll support.

    func talks(page: Int = 1) async throws -> Page<Talk> {
        try await client.talks(page: page)
    }

    func recentTalks(page: Int) async throws -> Page<Talk> {
        try await client.recentTalks(page: page)
    }

    func popularTalks(in year: Int, page: Int) async throws -> Page<Talk> {
        try await client.popularTalks(in: year, page: page)
    }

    func unpopularTalks(in year: Int, page: Int = 1) async throws -> Page<Talk> {
        try await client.unpopularTalks(in: year, page: page)
    }

    func searchTalks(query: String, page: Int, perPage: Int? = nil) async throws -> Page<Talk> {
        try await client.searchTalks(query: query, page: page, perPage: perPage)
    }

    // MARK: Recordings

    func recordings(for talk: Talk) async throws -> [Recording] {
        try await client.recordings(for: talk)
    }

    func recording(id: Int) async throws -> Recording {
        try await client.recording(id: id)
    }
}
