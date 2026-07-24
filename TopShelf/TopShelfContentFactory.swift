//
//  TopShelfContentFactory.swift
//  TopShelf
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import MediaCCCApi
import Foundation
import TVServices

struct TopShelfContentFactory {
    func makeTopShelfSections(recentTalks: [Talk], popularTalks: [Talk])
        -> [TVTopShelfItemCollection<TVTopShelfSectionedItem>]
    {
        let recents = TVTopShelfItemCollection(items: makeTopShelfItems(talks: recentTalks))
        recents.title = String(localized: "Recent talks", comment: "Top shelf title")

        let popular = TVTopShelfItemCollection(items: makeTopShelfItems(talks: popularTalks))
        popular.title = String(localized: "Popular talks", comment: "Top shelf title")

        return [recents, popular]
    }

    private func makeTopShelfItems(talks: [Talk]) -> [TVTopShelfSectionedItem] {
        talks.map(makeTopShelfItem)
    }

    private func makeTopShelfItem(talk: Talk) -> TVTopShelfSectionedItem {
        let item = TVTopShelfSectionedItem(identifier: talk.id)
        item.imageShape = .hdtv
        item.title = talk.title
        item.setImageURL(talk.posterURL, for: .screenScale1x)
        item.displayAction = URL(string: "ccctube://talk/\(talk.id)")
            .map(TVTopShelfAction.init)
        item.playAction = URL(string: "ccctube://talk/\(talk.id)/play")
            .map(TVTopShelfAction.init)
        return item
    }
}
