//
//  AppCoordinatorTests.swift
//  HackerTubeTests
//
//  Created by Mathijs Bernson on 02/11/2026.
//

import MediaCCCApi
import Testing

@testable import HackerTube

@MainActor
@Suite struct AppCoordinatorTests {
    let coordinator = AppCoordinator(playback: PlaybackController())
    let otherID = "44ab627f-ed5d-522b-b84b-15a3ed761895"

    @Test func `Deep link is pushed onto the selected tab only`() {
        coordinator.selectedTab = .popular
        coordinator.open(.talk(id: otherID, action: .open))

        #expect(coordinator.paths[.popular] == [.deepLinkedTalk(id: otherID, autoplay: false)])
        for tab in AppTab.allCases where tab != .popular {
            #expect(coordinator.paths[tab, default: []].isEmpty)
        }
    }

    @Test func `Deep link is pushed on the search tab`() {
        coordinator.selectedTab = .search
        coordinator.open(.talk(id: otherID, action: .open))

        #expect(coordinator.paths[.search] == [.deepLinkedTalk(id: otherID, autoplay: false)])
    }

    @Test func `Deep link is pushed on top of an existing stack`() {
        coordinator.selectedTab = .conferences
        coordinator.push(.conference(.example))
        coordinator.push(.talk(.example))

        coordinator.open(.talk(id: otherID, action: .open))

        #expect(
            coordinator.currentPath == [
                .conference(.example),
                .talk(.example),
                .deepLinkedTalk(id: otherID, autoplay: false),
            ])
    }

    @Test func `Deep link to the talk on top is not pushed again`() {
        coordinator.push(.talk(.example))

        coordinator.open(.talk(id: Talk.example.id, action: .open))

        #expect(coordinator.currentPath == [.talk(.example)])
    }

    @Test func `Repeated deep link is not pushed again`() {
        coordinator.open(.talk(id: otherID, action: .open))
        coordinator.open(.talk(id: otherID, action: .open))

        #expect(coordinator.currentPath == [.deepLinkedTalk(id: otherID, autoplay: false)])
    }

    @Test func `Play deep link pushes with autoplay`() {
        coordinator.open(.talk(id: otherID, action: .play))

        #expect(coordinator.currentPath == [.deepLinkedTalk(id: otherID, autoplay: true)])
    }

    @Test func `Play deep link to the talk on top starts playback there`() {
        coordinator.push(.talk(.example))

        coordinator.open(.talk(id: Talk.example.id, action: .play))

        #expect(coordinator.currentPath == [.deepLinkedTalk(id: Talk.example.id, autoplay: true)])
    }

    @Test func `Deep link dismisses the player`() {
        coordinator.isPlayerPresented = true

        coordinator.open(.talk(id: otherID, action: .open))

        #expect(coordinator.isPlayerPresented == false)
    }

    @Test func `Restore pushes the playing talk`() async {
        coordinator.push(.conference(.example))

        await coordinator.restore(talk: .example, recording: .example)

        #expect(coordinator.currentPath == [.conference(.example), .talk(.example)])
    }

    @Test func `Restore does not push the talk when it is already on top`() async {
        coordinator.push(.talk(.example))

        await coordinator.restore(talk: .example, recording: .example)

        #expect(coordinator.currentPath == [.talk(.example)])
    }
}
