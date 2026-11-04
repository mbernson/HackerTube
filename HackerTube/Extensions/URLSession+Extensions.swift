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

    /// URLSession for making calls to the `media.ccc.de` API
    static let mediaCCCApi: URLSession = {
        // The API answers with `Cache-Control: max-age=0, must-revalidate` and an ETag, so every request is
        // revalidated. The larger cache makes sure the 300 KB listing pages survive until the `304 Not Modified`.
        let directory = URL.cachesDirectory.appending(path: "MediaCCCApi", directoryHint: .isDirectory)
        let cache = URLCache(
            memoryCapacity: 10_000_000, // 10 megabytes
            diskCapacity: 50_000_000, // 50 megabytes
            directory: directory
        )
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        return URLSession(configuration: configuration)
    }()
}
