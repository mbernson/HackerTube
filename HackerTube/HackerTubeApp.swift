//
//  HackerTubeApp.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import AVKit
import SwiftUI
import CCCApi

@main
struct HackerTubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ApiService.shared)
                .onAppear {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch {}
                }
        }
    }
}
