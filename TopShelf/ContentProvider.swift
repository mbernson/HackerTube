//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import TVServices

class ContentProvider: TVTopShelfContentProvider {
    let factory = TopShelfContentFactory()

    override func loadTopShelfContent() async -> TVTopShelfContent? {
        do {
            let api = await ApiService.shared
            async let recentTalks = api.recentTalks()
            let currentYear = Calendar.current.component(.year, from: .now)
            async let popularTalks = api.popularTalks(in: currentYear)
            let sections = try factory.makeTopShelfSections(
                recentTalks: await recentTalks,
                popularTalks: await popularTalks
            )
            return TVTopShelfSectionedContent(sections: sections)
        } catch {
            return nil
        }
    }
}
