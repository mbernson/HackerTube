//
//  DeepLink.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import Foundation

/// A location inside the app that can be reached from outside of it, such as from the tvOS Top Shelf.
///
/// Deep links are represented as `ccctube://` URLs. This type is shared with the Top Shelf extension,
/// so the URLs it produces and the URLs the app accepts are always defined in one place.
enum DeepLink: Equatable, Hashable, Sendable {
    enum TalkAction: Equatable, Hashable, Sendable {
        /// Show the talk's detail screen.
        case open
        /// Show the talk's detail screen and immediately start playback.
        case play
    }

    case talk(id: String, action: TalkAction)

    static let scheme = "ccctube"

    init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        guard url.host == "talk" else { return nil }

        let components = url.pathComponents.filter { $0 != "/" }
        guard let id = components.first, !id.isEmpty else { return nil }

        if components.count >= 2, components.last == "play" {
            self = .talk(id: id, action: .play)
        } else {
            self = .talk(id: id, action: .open)
        }
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .talk(let id, let action):
            components.host = "talk"
            switch action {
            case .open:
                components.path = "/\(id)"
            case .play:
                components.path = "/\(id)/play"
            }
        }
        // The components above are always valid, so this can't fail.
        return components.url!
    }
}
