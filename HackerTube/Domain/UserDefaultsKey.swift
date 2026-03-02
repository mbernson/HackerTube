//
//  UserDefaultsKey.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 11/08/2025.
//

import Foundation

enum UserDefaultsKey: String {
    case playbackRate
    case lowDataModeEnabled
}

extension UserDefaults {
    @objc dynamic var playbackRate: Float {
        get { float(forKey: UserDefaultsKey.playbackRate.rawValue) }
        set { setValue(newValue, forKey: UserDefaultsKey.playbackRate.rawValue) }
    }

    @objc dynamic var lowDataModeEnabled: Bool {
        get { bool(forKey: UserDefaultsKey.lowDataModeEnabled.rawValue) }
        set { setValue(newValue, forKey: UserDefaultsKey.lowDataModeEnabled.rawValue) }
    }
}
