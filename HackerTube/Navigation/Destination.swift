//
//  Destination.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import MediaCCCApi
import SwiftUI

/// A screen that can be pushed onto a tab's navigation stack.
enum Destination: Hashable {
    /// A talk that has already been loaded, e.g. from a grid.
    case talk(Talk)
    /// An overview page for a particular conference (like Congress for a certain year).
    case conference(Conference)
    /// A talk that is only known by its identifier, e.g. from a deep link. It is loaded by the destination view.
    case deepLinkedTalk(id: String, autoplay: Bool)

    /// The identifier of the talk shown by this destination, if any.
    var talkID: String? {
        switch self {
        case .talk(let talk): talk.id
        case .deepLinkedTalk(let id, _): id
        case .conference: nil
        }
    }

    // `Talk` and `Conference` are not `Hashable`, so we have to implement the conformance manually.
    // The identity is based on the case and the model's `id`.

    static func == (lhs: Destination, rhs: Destination) -> Bool {
        switch (lhs, rhs) {
        case (.talk(let lhs), .talk(let rhs)):
            lhs.id == rhs.id
        case (.conference(let lhs), .conference(let rhs)):
            lhs.id == rhs.id
        case (.deepLinkedTalk(let lhsID, let lhsAutoplay), .deepLinkedTalk(let rhsID, let rhsAutoplay)):
            lhsID == rhsID && lhsAutoplay == rhsAutoplay
        default:
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .talk(let talk):
            hasher.combine(0)
            hasher.combine(talk.id)
        case .conference(let conference):
            hasher.combine(1)
            hasher.combine(conference.id)
        case .deepLinkedTalk(let id, let autoplay):
            hasher.combine(2)
            hasher.combine(id)
            hasher.combine(autoplay)
        }
    }
}

extension View {
    /// Registers the views for every ``Destination`` on the enclosing navigation stack.
    func appDestinations() -> some View {
        navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .talk(let talk):
                TalkView(talk: talk)
            case .conference(let conference):
                ConferenceView(conference: conference)
            case .deepLinkedTalk(let id, let autoplay):
                DeepLinkedTalkView(id: id, autoplay: autoplay)
            }
        }
    }
}
