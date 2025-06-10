//
//  ConferencesView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
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
                ConferencesGrid(
                    conferences: filterQuery.isEmpty
                        ? conferences
                        : conferences.filter { conference in
                            conference.title.lowercased().contains(filterQuery)
                        })
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
                .filter { conference in
                    conference.eventLastReleasedAt != nil
                }
                .sorted { lhs, rhs in
                    let lhsVal = lhs.eventLastReleasedAt ?? lhs.updatedAt
                    let rhsVal = rhs.eventLastReleasedAt ?? rhs.updatedAt
                    return lhsVal > rhsVal
                }
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}

struct ConferencesGrid: View {
    let conferences: [Conference]

    #if os(tvOS)
        let columns: [GridItem] = Array(repeating: GridItem(), count: 4)
    #else
        let columns: [GridItem] = Array(
            repeating: GridItem(.adaptive(minimum: 200, maximum: 400)),
            count: 2)
    #endif

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(conferences) { conference in
                NavigationLink {
                    ConferenceView(conference: conference)
                } label: {
                    ConferenceCell(conference: conference)
                        #if os(visionOS)
                            .padding()
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                            .hoverEffect(.lift)
                        #endif
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        #if os(tvOS)
            .focusSection()
            .buttonStyle(.card)
        #endif
        .accessibilityIdentifier("ConferencesGrid")
        .accessibilityElement(children: .contain)
    }
}

struct ConferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ConferencesView()
    }
}
