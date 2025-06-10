//
//  SearchView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

struct SearchView: View {
    @State var searchContext = SearchContext()
    @State var results: [Talk] = []
    @State var query = ""
    @State var isLoading = false
    @State var error: Error?
    @State var suggestions: [SearchSuggestion] = SearchSuggestion.defaultSuggestions.shuffled()
    @Environment(ApiService.self) var api

    var body: some View {
        NavigationStack {
            Group {
                #if os(tvOS)
                    List {
                        ForEach(results) { talk in
                            NavigationLink {
                                TalkView(talk: talk)
                            } label: {
                                TalkListItem(talk: talk)
                            }

                        }
                    }
                #else
                    if isLoading {
                        ProgressView()
                    } else if results.isEmpty && !query.isEmpty {
                        Text("No talks found")
                    } else if results.isEmpty {
                        List {
                            ForEach(suggestions) { suggestion in
                                Button(suggestion.title) {
                                    query = suggestion.title
                                    runSearch()
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        ScrollView {
                            TalksGrid(talks: results)
                        }
                    }
                #endif
            }
            #if !os(tvOS)
                .navigationTitle("Search")
            #endif
            .searchable(text: $query, prompt: "Search talks...")
            .onChange(of: query) { _, query in
                searchContext.send(query: query)
            }
            .onReceive(searchContext.searchQueryPublisher) { query in
                runSearch(query)
            }
            #if os(tvOS)
                .searchSuggestions {
                    ForEach(suggestions) { suggest in
                        Text(suggest.title).searchCompletion(suggest.title)
                    }
                }
            #endif
            .onAppear(perform: runSearch)
            .onSubmit(of: .search, runSearch)
            .alert("Failed to load data from the media.ccc.de API", error: $error)
        }
    }

    func runSearch() {
        runSearch(query)
    }

    func runSearch(_ query: String) {
        if query.isEmpty {
            results.removeAll()
        } else {
            Task {
                await search(query)
            }
        }
    }

    func search(_ query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            results = try await api.searchTalks(query: query)
        } catch {
            self.error = error
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
