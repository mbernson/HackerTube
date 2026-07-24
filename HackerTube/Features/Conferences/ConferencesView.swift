//
//  ConferencesView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import MediaCCCApi
import SwiftUI

struct ConferencesView: View {
    @State var conferences: [Conference] = []
    @State var filterQuery = ""
    @State var isLoading = true
    @State var error: Error?
    @Environment(ApiService.self) var api

    var body: some View {
        NavigationStack {
            ScrollView {
                let filterQuery = filterQuery.lowercased()
                let conferences: [Conference] = filterQuery.isEmpty
                ? conferences
                : conferences.filter { conference in
                    conference.title.lowercased().contains(filterQuery)
                }
                ConferencesGrid(conferences: conferences)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            #if !os(tvOS)
                .searchable(text: $filterQuery)
                .navigationTitle("Conferences")
            #endif
            .task {
                isLoading = true
                defer { isLoading = false }
                await refresh()
            }
            .refreshable {
                await refresh()
            }
            .alert("Failed to load data from the media.ccc.de API", error: $error)
        }
    }

    func refresh() async {
        do {
            conferences = try await api.conferences()
                .sorted { lhs, rhs in
                    // Sort by updated at, falling back to title sort.
                    if let lhsUpdatedAt = lhs.eventLastReleasedAt ?? lhs.updatedAt,
                       let rhsUpdatedAt = rhs.eventLastReleasedAt ?? rhs.updatedAt {
                        return lhsUpdatedAt > rhsUpdatedAt
                    } else {
                        return lhs.title < rhs.title
                    }
                }
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ConferencesView()
}
