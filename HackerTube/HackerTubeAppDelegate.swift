//
//  HackerTubeAppDelegate.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 11/08/2025.
//

import UIKit

class HackerTubeAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDefaultSettings()
        return true
    }

    private func registerDefaultSettings() {
        UserDefaults.standard.register(defaults: [
            UserDefaultsKey.playbackRate.rawValue : 1.0 as Float,
            UserDefaultsKey.lowDataModeEnabled.rawValue : false,
        ])
    }
}
