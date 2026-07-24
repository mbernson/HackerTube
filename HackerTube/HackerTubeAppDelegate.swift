//
//  HackerTubeAppDelegate.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 11/08/2025.
//

import AVFAudio
import UIKit
import os.log

class HackerTubeAppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: "HackerTubeAppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDefaultSettings()
        configureAudioSession()
        return true
    }

    private func registerDefaultSettings() {
        UserDefaults.standard.register(defaults: [
            UserDefaultsKey.playbackRate.rawValue : 1.0 as Float,
        ])
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            logger.error("Failed to configure audio session: \(error)")
        }
    }
}
