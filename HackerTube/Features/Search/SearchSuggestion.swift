//
//  SearchSuggestion.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 31/07/2022.
//

import Foundation

struct SearchSuggestion: Identifiable {
    let title: String
    var id: String { title }
}

extension SearchSuggestion {
    static let defaultSuggestions: [SearchSuggestion] = {
        guard let url = Bundle.main.url(forResource: "SearchSuggestions", withExtension: "json5"),
              let data = try? Data(contentsOf: url)
        else { return [] }
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        guard let titles = try? decoder.decode([String].self, from: data) else { return [] }
        return titles.map(SearchSuggestion.init)
    }()
}
