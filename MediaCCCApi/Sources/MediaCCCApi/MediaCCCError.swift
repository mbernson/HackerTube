//
//  MediaCCCError.swift
//  MediaCCCApi
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import Foundation

/// Errors thrown by ``MediaCCCApiClient`` when talking to the media.ccc.de API.
public enum MediaCCCError: LocalizedError, CustomNSError {
    /// The transport layer failed, e.g. the device is offline or the request timed out.
    case network(URLError)
    /// The server's response was not an HTTP response, so it could not be interpreted.
    case invalidResponse
    /// The server responded with a non-success (non-2xx) status code, e.g. 404 or 500.
    case httpError(statusCode: Int)
    /// The response body could not be decoded into the expected model.
    case decodingFailed(underlying: Error)

    // MARK: LocalizedError

    public var errorDescription: String? {
        switch self {
        case .network:
            return String(localized: "Couldn't reach media.ccc.de. Check your internet connection and try again.", bundle: .module)
        case .invalidResponse:
            return String(localized: "media.ccc.de sent an unexpected response. Please try again later.", bundle: .module)
        case .httpError(let statusCode):
            if statusCode == 404 {
                return String(localized: "This content couldn't be found on media.ccc.de.", bundle: .module)
            } else if (500..<600).contains(statusCode) {
                return String(localized: "media.ccc.de is having problems right now. Please try again later.", bundle: .module)
            } else {
                return String(localized: "media.ccc.de returned an error. Please try again later.", bundle: .module)
            }
        case .decodingFailed:
            return String(localized: "Received unexpected data from media.ccc.de. Please try again later.", bundle: .module)
        }
    }

    // MARK: CustomNSError (monitoring — stable domain and codes)

    public static let errorDomain = "MediaCCCApi.MediaCCCError"

    /// Stable, hand-assigned codes. Do not renumber existing cases; append new ones.
    public var errorCode: Int {
        switch self {
        case .network: return 1
        case .invalidResponse: return 2
        case .httpError: return 3
        case .decodingFailed: return 4
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .network(let underlying):
            return [NSUnderlyingErrorKey: underlying]
        case .invalidResponse:
            return [:]
        case .httpError(let statusCode):
            return ["statusCode": statusCode]
        case .decodingFailed(let underlying):
            return [NSUnderlyingErrorKey: underlying]
        }
    }
}
