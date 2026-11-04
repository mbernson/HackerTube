//
//  URLSession+Extensions.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 04/11/2026.
//

import Foundation
import OSLog

extension URLSession {
    /// URLSession with a cache intended for talk thumbnails, conference logos, etcetera.
    static let remoteImages: URLSession = {
        let directory = URL.cachesDirectory.appending(path: "RemoteImages", directoryHint: .isDirectory)
        let cache = URLCache(
            memoryCapacity: 20_000_000, // 20 megabytes
            diskCapacity: 100_000_000, // 100 megabytes
            directory: directory
        )
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        return URLSession(configuration: configuration)
    }()
}
