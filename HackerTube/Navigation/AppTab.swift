//
//  AppTab.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 02/11/2026.
//

/// The top-level tabs of the app. Each tab has its own navigation stack.
enum AppTab: Hashable, CaseIterable, Sendable {
    case recent
    case popular
    case conferences
    case search
}
