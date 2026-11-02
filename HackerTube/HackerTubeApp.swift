//
//  HackerTubeApp.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI
import MediaCCCApi

@main
struct HackerTubeApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: HackerTubeAppDelegate

    @State private var api = ApiService()
    @State private var playback: PlaybackController
    @State private var coordinator: AppCoordinator

    init() {
        let playback = PlaybackController()
        let coordinator = AppCoordinator(playback: playback)
        playback.onRestoreUserInterface = { [weak coordinator] talk, recording in
            await coordinator?.restore(talk: talk, recording: recording)
        }
        _playback = State(initialValue: playback)
        _coordinator = State(initialValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(api)
                .environment(playback)
                .environment(coordinator)
        }
    }
}
