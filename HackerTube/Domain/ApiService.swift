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

    func conference(acronym: String) async throws -> Conference {
        try await client.conference(acronym: acronym)
    }

    // MARK: Talks

    func talk(id: String) async throws -> Talk {
        try await client.talk(id: id)
    }

//    func talks() async throws -> [Talk] {
//        try await client.talks()
//    }

    func recentTalks() async throws -> [Talk] {
        try await client.recentTalks()
    }

    func popularTalks(in year: Int) async throws -> [Talk] {
        try await client.popularTalks(in: year)
    }

    func searchTalks(query: String) async throws -> [Talk] {
        try await client.searchTalks(query: query)
    }

    // MARK: Recordings

    func recordings(for talk: Talk) async throws -> [Recording] {
        try await client.recordings(for: talk)
    }
}
