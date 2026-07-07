//
//  SettingsView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/03/2026.
//

import SwiftUI
import AVKit

enum RecordingQuality: String {
    case hd, sd
}

struct SettingsView: View {
    @AppStorage(UserDefaultsKey.lowDataModeEnabled.rawValue)
    var lowDataModeEnabled = false

    @AppStorage(UserDefaultsKey.playbackRate.rawValue)
    var playbackRate: Double = 1.0
    let playbackRates: [Double] = AVPlaybackSpeed.systemDefaultSpeeds.map(\.rate).map(Double.init)

    var body: some View {
        NavigationStack {
            List {
                Section("Playback") {
                    Picker("Playback speed", selection: $playbackRate) {
                        ForEach(playbackRates, id: \.self) { playbackRate in
                            Text("\(playbackRate, format: .number) ×", comment: "Playback rate").tag(playbackRate)
                        }
                    }
                }

                Section {
                    Toggle("Low data mode", isOn: $lowDataModeEnabled)
                } header: {
                    Text("Streaming")
                } footer: {
                    Text("When low data mode is on, HackerTube will play standard definition (SD) video instead of HD when possible.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
