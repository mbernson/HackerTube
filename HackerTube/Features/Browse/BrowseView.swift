//
//  BrowseView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

enum EventsQuery: Equatable {
    case recent
    case popular

    var localizedTitle: String {
        switch self {
        case .recent:
            return String(localized: "Recent")
        case .popular:
            return String(localized: "Popular")
        }
    }
}

struct BrowseView: View {
    let query: EventsQuery
    @State var year: Int = Calendar.current.component(.year, from: .now)
    @State var talks: [Talk] = []
    @State var isLoading = true
    @State var error: Error?
    @Environment(ApiService.self) var api

    var body: some View {
        NavigationStack {
            ScrollView {
                #if os(tvOS)
                    if query == .popular {
                        YearPicker(year: $year)
                    }
                #endif

                TalksGrid(talks: talks)
            }
            .toolbar {
                #if !os(tvOS)
                    if query == .popular {
                        ToolbarItem(placement: .topBarTrailing) {
                            YearPicker(year: $year)
                        }
                    }
                #endif
            }
            .overlay {
                if isLoading {
                    ProgressView()
                } else if talks.isEmpty {
                    Text("No talks found")
                }
            }
            #if !os(tvOS)
                .navigationTitle(query.localizedTitle)
            #endif
            .task(id: year) {
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
            switch query {
            case .recent:
                talks = try await api.recentTalks()
            case .popular:
                talks = try await api.popularTalks(in: year)
            }
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}

struct YearPicker: View {
    @Binding var year: Int
    let firstYear: Int = 2000
    let currentYear = Calendar.current.component(.year, from: .now)
    var body: some View {
        Picker(selection: $year) {
            ForEach(Array(firstYear...currentYear).reversed(), id: \.self) { year in
                Text(String(year))
                    .tag(year)
            }
        } label: {
            Label("Year", systemImage: "calendar")
        }
        .pickerStyle(.menu)
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(query: .popular, talks: [.example])
    }
}
